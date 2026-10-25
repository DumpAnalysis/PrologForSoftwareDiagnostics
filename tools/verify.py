#!/usr/bin/env python3
"""
Verification harness for the book's Prolog code.

Scans Markdown chapter files for fenced code blocks and replays them
through a real SWI-Prolog toplevel (running under a pseudo-terminal so the
toplevel behaves exactly as it does for a human reader).

Block conventions (pandoc fenced-code attributes):

  ```{.prolog .program}            program text; consulted into the running
                                    toplevel (each block becomes its own file)
  ```{.prolog .program file=NAME}  as above, but stored under NAME so that
                                    consult(NAME) / use_module(NAME) work
  ```{.prolog .query}              toplevel transcript: lines starting with
                                    "?- " are queries; the lines that follow,
                                    up to the next "?- " line, are the expected
                                    toplevel output
  ```{.prolog .fresh ...}          start a new toplevel before this block
  ```{.prolog .warn ...}           consult warnings are expected (not failures)
  ```{.prolog}                     illustrative only; read-checked for syntax
  ```{.prolog .noverify}           skipped entirely
  ```{.prolog .query .sitepath}    the output shows the SWI-Prolog
                                    installation directory of the drafting
                                    machine (/usr/lib/swi-prolog); the
                                    installation directory of the machine
                                    running the check (the flag `home`) is
                                    replaced by it before matching, and
                                    nothing else is normalised
  ```{.text} / ```{.windbg} ...    not Prolog; ignored

Expected-output matching: exact after whitespace normalisation, except that
a line consisting solely of "..." matches any number of lines, and "<...>"
inside a line matches any substring.

Usage:  verify.py CHAPTER.md [CHAPTER2.md ...] [-v] [--keep]
Exit status 0 iff every verified block passed.
"""
import os, re, sys, pty, time, select, termios, tty, signal, shutil, tempfile, hashlib, subprocess

MANUSCRIPT_HOME = '/usr/lib/swi-prolog'


def swipl_home():
    """The installation directory of the swipl that runs the checks."""
    try:
        out = subprocess.run([SWIPL, '-q', '-g', 'current_prolog_flag(home, H), write(H), nl', '-t', 'halt'],
                             capture_output=True, text=True, timeout=30).stdout.strip()
        return out or MANUSCRIPT_HOME
    except Exception:
        return MANUSCRIPT_HOME

FENCE_RE = re.compile(r'^(`{3,}|~{3,})\s*(\{[^}]*\}|[\w+-]*)\s*$')
PROMPT = '?- '
SWIPL = shutil.which('swipl') or '/usr/bin/swipl'


def parse_attrs(spec):
    spec = spec.strip()
    classes, kv = [], {}
    if spec.startswith('{'):
        body = spec[1:-1]
        for tok in re.findall(r'\.[\w-]+|#[\w-]+|[\w-]+=(?:"[^"]*"|\S+)', body):
            if tok.startswith('.'):
                classes.append(tok[1:])
            elif tok.startswith('#'):
                kv['id'] = tok[1:]
            else:
                k, v = tok.split('=', 1)
                kv[k] = v.strip('"')
    elif spec:
        classes.append(spec)
    return classes, kv


def extract_blocks(text):
    """Yield (lineno, classes, kv, code) for every fenced block."""
    lines = text.split('\n')
    i = 0
    while i < len(lines):
        m = FENCE_RE.match(lines[i])
        if m:
            fence, spec = m.group(1), m.group(2)
            classes, kv = parse_attrs(spec)
            start = i + 1
            j = start
            while j < len(lines) and not (lines[j].startswith(fence[0] * len(fence))
                                          and lines[j].strip() == fence[0] * len(fence)):
                j += 1
            yield start, classes, kv, '\n'.join(lines[start:j])
            i = j + 1
        else:
            i += 1


class Toplevel:
    """A SWI-Prolog toplevel driven through a pty."""

    def __init__(self, cwd):
        self.cwd = cwd
        pid, fd = pty.fork()
        if pid == 0:
            os.chdir(cwd)
            os.environ['TERM'] = 'dumb'
            os.environ['LANG'] = 'C.UTF-8'
            os.execv(SWIPL, [SWIPL, '-q',
                             '-g', 'set_prolog_flag(color_term,false)',
                             '-g', 'set_prolog_flag(toplevel_prompt,\'?- \')',
                             '-g', 'set_prolog_flag(verbose_load,silent)'])
        self.pid, self.fd = pid, fd
        attrs = termios.tcgetattr(fd)
        attrs[3] = attrs[3] & ~termios.ECHO
        termios.tcsetattr(fd, termios.TCSANOW, attrs)
        self.buf = ''
        self._read_until_prompt(timeout=20)

    def _read(self, timeout):
        r, _, _ = select.select([self.fd], [], [], timeout)
        if not r:
            return None
        try:
            data = os.read(self.fd, 65536)
        except OSError:
            return ''
        return data.decode('utf-8', 'replace')

    def _read_until_prompt(self, timeout=30):
        """Read until the toplevel shows a fresh '?- ' prompt, answering ';'
        whenever it stops to ask for the next solution. Returns output."""
        out = ''
        deadline = time.time() + timeout
        idle = 0.0
        presses = 0
        while True:
            chunk = self._read(0.05)
            if chunk is None:
                idle += 0.05
                if time.time() > deadline:
                    out += '\n<<TIMEOUT>>'
                    return out
                # The toplevel waits for an action after printing a solution
                # that leaves choice points.  We detect that by inactivity
                # after a solution line that is not terminated by '.'.
                if idle >= 0.25 and self._awaiting_action(out):
                    presses += 1
                    if presses > 40:
                        os.write(self.fd, b'.')
                        out += '\n<<MORE SOLUTIONS NOT SHOWN>>'
                    else:
                        os.write(self.fd, b';')
                    idle = 0.0
                continue
            idle = 0.0
            out += chunk.replace('\r\n', '\n').replace('\r', '')
            if re.search(r'(^|\n)\?- $', out):
                return out[:out.rfind(PROMPT)]

    @staticmethod
    def _awaiting_action(out):
        tail = out.rstrip('\n')
        last = tail.split('\n')[-1] if tail else ''
        if last.endswith('?- '):
            return False
        if last.startswith('ERROR') or last.startswith('Warning'):
            return False
        # toplevel prints "X = 1 " or "true " and stops
        return last.endswith(' ') and not last.rstrip().endswith('.') \
            and not last.rstrip().endswith(';')

    def query(self, q, timeout=60):
        q = q.strip()
        if not q.endswith('.'):
            q += '.'
        os.write(self.fd, (q + '\n').encode())
        out = self._read_until_prompt(timeout)
        return out

    def consult(self, path, timeout=60):
        return self.query("consult('%s')" % path, timeout)

    def close(self):
        try:
            os.write(self.fd, b'halt.\n')
        except OSError:
            pass
        try:
            os.kill(self.pid, signal.SIGKILL)
        except OSError:
            pass
        try:
            os.waitpid(self.pid, 0)
        except OSError:
            pass
        try:
            os.close(self.fd)
        except OSError:
            pass


def norm(s):
    lines = [l.rstrip() for l in s.replace('\r', '').split('\n')]
    return [l for l in lines if l.strip() != '']


def match_expected(expected, actual):
    """Match normalised expected lines (with ... and <...> wildcards) against actual."""
    exp, act = norm(expected), norm(actual)

    def line_match(e, a):
        if '<...>' in e:
            parts = [re.escape(p) for p in e.split('<...>')]
            return re.fullmatch('.*'.join(parts), a) is not None
        return e == a

    # dynamic programming over wildcard lines
    def rec(i, j):
        if i == len(exp):
            return j == len(act)
        if exp[i] == '...':
            for k in range(j, len(act) + 1):
                if rec(i + 1, k):
                    return True
            return False
        if j < len(act) and line_match(exp[i], act[j]):
            return rec(i + 1, j + 1)
        return False
    return rec(0, 0)


def split_transcript(code):
    """Split a .query block into [(query, expected), ...]."""
    items = []
    cur_q, cur_out = None, []
    for line in code.split('\n'):
        if line.startswith(PROMPT):
            if cur_q is not None:
                items.append((cur_q, '\n'.join(cur_out)))
            cur_q, cur_out = line[len(PROMPT):], []
        elif cur_q is not None and line.startswith('   ') and not cur_out and not line.strip().endswith('.') is None:
            # continuation of a multi-line query (indented, before any output)
            cur_q += ' ' + line.strip()
        else:
            if cur_q is not None:
                cur_out.append(line)
    if cur_q is not None:
        items.append((cur_q, '\n'.join(cur_out)))
    # continuation heuristic: a query that does not end with '.' absorbs
    # following lines until one ends with '.'
    fixed = []
    for q, out in items:
        if not q.rstrip().endswith('.'):
            outl = out.split('\n')
            while outl and not q.rstrip().endswith('.'):
                q += ' ' + outl.pop(0).strip()
            out = '\n'.join(outl)
        fixed.append((q, out))
    return fixed


def check_syntax(code, workdir):
    """Read-check an illustrative block: every clause must parse."""
    p = os.path.join(workdir, 'syntax_check.pl')
    with open(p, 'w') as f:
        f.write(code + '\n')
    import subprocess
    r = subprocess.run([SWIPL, '-q', '-g',
                        "catch((open('%s',read,S),repeat,read_term(S,T,[syntax_errors(error)]),T==end_of_file,!,close(S)),E,(print_message(error,E),halt(1)))" % p,
                        '-t', 'halt'], capture_output=True, text=True, timeout=30)
    return r.returncode == 0, r.stderr


SHARED = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'src', 'shared')
MAX_CODE_WIDTH = 50
MAX_TEXT_WIDTH = 64


def verify_file(path, verbose=False, keep=False):
    text = open(path, encoding='utf-8').read()
    workdir = tempfile.mkdtemp(prefix='pbook_')
    if os.path.isdir(SHARED):
        for fn in os.listdir(SHARED):
            if fn.endswith('.pl') or fn.endswith('.txt') or fn.endswith('.log') or fn.endswith('.csv'):
                shutil.copy(os.path.join(SHARED, fn), workdir)
    failures, checked = [], 0
    # width check for every fenced block
    for lineno, classes, kv, code in extract_blocks(text):
        limit = MAX_CODE_WIDTH if ('prolog' in classes and 'small' not in classes) else MAX_TEXT_WIDTH
        for k, line in enumerate(code.split('\n')):
            if len(line.rstrip()) > limit:
                failures.append((lineno + k, 'width', 'line of %d chars exceeds %d' % (len(line.rstrip()), limit), line.rstrip()))
    top = None
    blockno = 0
    try:
        for lineno, classes, kv, code in extract_blocks(text):
            if 'prolog' not in classes:
                continue
            if 'noverify' in classes:
                continue
            blockno += 1
            if 'fresh' in classes or top is None:
                if top:
                    top.close()
                top = Toplevel(workdir)
            if 'program' in classes:
                name = kv.get('file', 'block_%03d.pl' % blockno)
                fpath = os.path.join(workdir, name)
                os.makedirs(os.path.dirname(fpath), exist_ok=True)
                with open(fpath, 'w') as f:
                    f.write(code + '\n')
                out = top.consult(fpath)
                checked += 1
                bad = ('ERROR' in out) or ('Warning' in out and 'warn' not in classes) or ('<<TIMEOUT>>' in out)
                if bad or 'true.' not in out:
                    failures.append((lineno, 'program', code, out))
                elif verbose:
                    print('  ok program @%d' % lineno)
            elif 'query' in classes:
                for q, expected in split_transcript(code):
                    checked += 1
                    out = top.query(q)
                    if 'sitepath' in classes:
                        home = swipl_home()
                        if home != MANUSCRIPT_HOME:
                            out = out.replace(home, MANUSCRIPT_HOME)
                    if not match_expected(expected, out):
                        failures.append((lineno, 'query: ' + q, expected, out))
                    elif verbose:
                        print('  ok query @%d: %s' % (lineno, q))
            else:
                ok, err = check_syntax(code, workdir)
                checked += 1
                if not ok:
                    failures.append((lineno, 'syntax', code, err))
                elif verbose:
                    print('  ok syntax @%d' % lineno)
    finally:
        if top:
            top.close()
        if not keep:
            shutil.rmtree(workdir, ignore_errors=True)
    return checked, failures


def main(argv):
    verbose = '-v' in argv
    keep = '--keep' in argv
    files = [a for a in argv if not a.startswith('-')]
    total_bad = 0
    for f in files:
        checked, failures = verify_file(f, verbose, keep)
        status = 'PASS' if not failures else 'FAIL'
        print('%s %s: %d checks, %d failures' % (status, f, checked, len(failures)))
        for lineno, kind, expected, actual in failures:
            total_bad += 1
            print('-' * 70)
            print('%s:%d  [%s]' % (f, lineno, kind))
            print('--- expected/program ---')
            print(expected.rstrip())
            print('--- actual ---')
            print(actual.rstrip())
    return 1 if total_bad else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))

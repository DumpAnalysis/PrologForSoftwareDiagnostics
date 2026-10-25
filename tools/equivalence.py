#!/usr/bin/env python3
"""
Equivalence check: the shared module src/shared/patterns_dump.pl against
the canonical chapter definitions (Chapters 18-22, plus suspended_thread/1
of Chapter 1).

For each chapter, every program block is loaded into a module of its own
(ch18, ch19, ...) with the shared dump loaded once into `user` as dynamic
facts.  Then, for every predicate exported by patterns_dump that the chapter
defines:

  1. clause equivalence: the clause lists are compared as variants after
     removing user: qualifications (the module qualifies the dump relations,
     the chapters do not);
  2. answer equivalence on the shared fixture: both definitions are run on
     dump1.pl and their answer sets compared;
  3. answer equivalence on synthetic facts: the reviewer's stack-overflow
     cases (12-frame stacks with runs 4, 5 and 6; an 8-frame stack with a
     run of 6; a short stack with the overflow status code) and the
     deadlock cases (a parallel mutant edge; a pure mutant cycle) are
     asserted and both definitions queried.

Usage: equivalence.py [-v]   (exit 0 iff every expected comparison is present
       and agrees, and the SWI-Prolog process exited normally; the last line
       is an EQUIVALENCE SUMMARY with PASS or FAIL)
"""
import os, re, sys, subprocess, tempfile, shutil
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import verify

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'src')
SHARED = os.path.join(SRC, 'shared')

CHAPTERS = {
    'ch01': '01-why-prolog.md',
    'ch18': '18-stack-traces-and-threads.md',
    'ch19': '19-exceptions-and-faults.md',
    'ch20': '20-synchronization.md',
    'ch21': '21-memory-and-resources.md',
    'ch22': '22-modules-and-environment.md',
}

# predicates whose canonical chapter is known (the module's own helpers for
# sufficiency checking are excluded)
CANON = {
    'ch01': ['suspended_thread/1'],
    'ch18': ['stack_trace/2', 'stack_trace_signature/2', 'main_thread/1', 'cpu_time/2',
             'total_cpu/1', 'cpu_share/2', 'spiking_thread/1', 'spiking_thread/2', 'blocked_thread/1',
             'blocked_thread/2', 'frame_regularity/3'],
    'ch19': ['exception_stack_trace/2', 'null_pointer_data/1', 'null_pointer_data/2', 'stack_depth/2',
             'stack_overflow/2'],
    'ch20': ['waits/3', 'wait_edge/3', 'wait_edge/4', 'edge_of/3', 'edge_of/4', 'wait_chain/2',
             'deadlock_witness/3', 'deadlock/2', 'deadlock/3'],
    'ch21': ['insufficient_memory/2', 'insufficient_memory/3', 'handle_leak/1', 'memory_leak/1'],
    'ch22': ['main_module/1', 'vendor/2', 'not_my_version/1', 'unknown_component/1',
             'no_component_symbols/1', 'hooked_functions/3', 'last_error_collection/1'],
}

PROLOG_DRIVER = r'''
:- style_check(-discontiguous).
:- style_check(-singleton).
:- dynamic user:thread/2, user:frame/5, user:exception_record/3, user:exception_info/3,
   user:critical_section/4, user:waits_for/3, user:waits_for_object/3, user:mutant/3,
   user:heap_at/5, user:dump_time/2.
:- use_module(library(lists)).
:- use_module(library(apply)).

strip_user(V, V) :- var(V), !.
strip_user(user:G, G1) :- !, strip_user(G, G1).
strip_user(T, T1) :- compound(T), !, T =.. [F|As], maplist(strip_user, As, As1), T1 =.. [F|As1].
strip_user(T, T).

clauses_of(M, Name/Arity, Cs) :-
    functor(H, Name, Arity),
    findall(H1-B1, ( clause(M:H, B), strip_user(H, H1), strip_user(B, B1) ), Cs0),
    maplist(norm_clause, Cs0, Cs).
norm_clause(H-B, C) :- copy_term(H-B, C), numbervars(C, 0, _).

same_clauses(Cs1, Cs2) :-
    length(Cs1, N), length(Cs2, N),
    forall(nth1(I, Cs1, C1), ( nth1(I, Cs2, C2), C1 =@= C2 )).

answers(M, Name/Arity, Set) :-
    functor(G, Name, Arity),
    catch(findall(G, M:G, L), E, (L = [error(E)])),
    maplist(norm_term, L, L1), msort(L1, Set).
norm_term(T, T1) :- copy_term(T, T1), numbervars(T1, 0, _).

% the chapters extend the shared fixture with facts of their own (further
% threads, mutexes, heap snapshots); for a fair comparison those facts are
% copied into user while the module is queried
fixture_relation(thread/2). fixture_relation(frame/5).
fixture_relation(exception_record/3). fixture_relation(exception_info/3).
fixture_relation(critical_section/4). fixture_relation(waits_for/3).
fixture_relation(waits_for_object/3). fixture_relation(mutant/3).
fixture_relation(heap_at/5). fixture_relation(dump_time/2).
fixture_relation(module/3). fixture_relation(module_info/3).
fixture_relation(thread_time/3). fixture_relation(thread_state/2).
fixture_relation(handle_count/3). fixture_relation(heap/4).
fixture_relation(last_error/2). fixture_relation(hooked/3).

with_chapter_facts(Ch, Goal) :-
    findall(F, ( fixture_relation(N/A), functor(F, N, A),
                 current_predicate(Ch:N/A),
                 \+ predicate_property(Ch:F, imported_from(_)),
                 catch(Ch:F, _, fail),
                 \+ catch(user:F, _, fail) ), Extra0),
    sort(Extra0, Extra),
    setup_call_cleanup(
        forall(member(F, Extra), ( functor(F, N, A), dynamic(user:N/A), assertz(user:F) )),
        Goal,
        forall(member(F, Extra), retract(user:F))).

check(Ch, PI, Result) :-
    (   catch(clauses_of(Ch, PI, Cc), _, fail), Cc \== []
    ->  clauses_of(patterns_dump, PI, Cm),
        ( same_clauses(Cc, Cm) -> R1 = identical ; R1 = different ),
        answers(Ch, PI, Ac),
        with_chapter_facts(Ch, answers(patterns_dump, PI, Am)),
        ( Ac == Am -> R2 = same_answers ; R2 = different_answers )
    ;   R1 = missing_in_chapter, R2 = -
    ),
    Result = R1/R2.

% synthetic cases for stack_overflow/2 and deadlock/3
% a synthetic fact goes into user (seen by the module) and into every
% chapter module that defines the relation itself (seen by that chapter)
add_fact(F) :-
    assertz(user:F),
    functor(F, N, A),
    forall(( member(M, [ch01,ch18,ch19,ch20,ch21,ch22]),
             current_predicate(M:N/A),
             \+ predicate_property(M:F, imported_from(_)) ),
           ( predicate_property(M:F, dynamic) -> assertz(M:F) ; true )).

synthetic_stack(TID, Fs) :-
    forall(nth0(N, Fs, F), add_fact(frame(TID, N, test, F, 0))),
    add_fact(thread(TID, 4120)).

add_synthetic :-
    synthetic_stack(201, [f,f,f,f,g,h,i,j,k,l,m,n]),
    synthetic_stack(202, [f,f,f,f,f,g,h,i,j,k,l,m]),
    synthetic_stack(203, [f,f,f,f,f,f,g,h,i,j,k,l]),
    synthetic_stack(204, [f,f,f,f,f,f,g,h]),
    synthetic_stack(205, [a,b,c]),
    add_fact(exception_record(205, 0xc00000fd, 0x7ffb00000000)),
    add_fact(waits_for_object(103, mutant, 1)),
    add_fact(mutant(1, 104, a)),
    add_fact(waits_for_object(201, mutant, 1)),
    add_fact(waits_for_object(202, mutant, 2)),
    add_fact(mutant(1, 202, a)),
    add_fact(mutant(2, 201, b)).

behaviour(Ch, Goal, R) :-
    copy_term(Goal, G1), copy_term(Goal, G2),
    catch(findall(G1, Ch:G1, L1), E1, L1 = [error(E1)]),
    with_chapter_facts(Ch, catch(findall(G2, patterns_dump:G2, L2), E2, L2 = [error(E2)])),
    maplist(norm_term, L1, S1a), msort(S1a, S1),
    maplist(norm_term, L2, S2a), msort(S2a, S2),
    ( S1 == S2 -> R = agree(S1) ; R = disagree(S1, S2) ).

report(Ch, PIs) :-
    format("~w~n", [Ch]),
    forall(member(PI, PIs),
           ( check(Ch, PI, R), format("  ~w ~w~n", [PI, R]) )).

behaviour_report(Ch, Goals) :-
    forall(member(G, Goals),
           ( behaviour(Ch, G, R),
             ( R = agree(S) -> length(S, N), format("  ~q: agree (~d answers)~n", [G, N])
             ; R = disagree(A, B) -> format("  ~q: DISAGREE~n    chapter: ~q~n    module:  ~q~n", [G, A, B]) ))).
'''


def chapter_blocks(md):
    text = open(os.path.join(SRC, md), encoding='utf-8').read()
    out = []
    for lineno, classes, kv, code in verify.extract_blocks(text):
        if 'prolog' in classes and 'program' in classes and 'noverify' not in classes:
            out.append((kv.get('file'), code))
    return out


# the synthetic cases listed in main() below: 7 + 5 + 4 + 2 + 5
EXPECTED_SYNTHETIC = 23


def main(argv):
    verbose = '-v' in argv
    work = tempfile.mkdtemp(prefix='equiv_')
    for fn in os.listdir(SHARED):
        shutil.copy(os.path.join(SHARED, fn), work)
    loader = ['% generated loader', PROLOG_DRIVER,
              ":- consult(dump1).", ":- use_module(patterns_dump)."]
    rels = ['thread/2', 'frame/5', 'exception_record/3', 'exception_info/3', 'critical_section/4',
            'waits_for/3', 'waits_for_object/3', 'mutant/3', 'heap_at/5', 'dump_time/2']
    for mod in CHAPTERS:
        loader.append(':- dynamic %s.' % ', '.join('%s:%s' % (mod, r) for r in rels))
        shutil.copy(os.path.join(SHARED, 'dump1.pl'), os.path.join(work, 'dump1_%s.pl' % mod))
    for mod, md in CHAPTERS.items():
        n = 0
        for fname, code in chapter_blocks(md):
            # chapters load their own copy of the dump into their module (as the
            # book does); a non-module file can be loaded into one module only,
            # so each chapter gets a private copy of dump1.pl under another name
            code = re.sub(r'^:- use_module\(patterns_dump[^\n]*$', '', code, flags=re.M)
            code = re.sub(r'^:- \[dump1\]\.', ':- [dump1_%s].' % mod, code, flags=re.M)
            code = re.sub(r'^:- include\(dump1\)\.', ':- include(dump1_%s).' % mod, code, flags=re.M)
            if fname and fname.endswith('.pl') and ':- module(' in code:
                continue    # module files of the chapter are not part of its user program
            n += 1
            path = os.path.join(work, fname if fname else '%s_%03d.pl' % (mod, n))
            with open(path, 'w') as f:
                f.write(code + '\n')
            loader.append(":- catch(%s:load_files('%s', [silent(true)]), E, (print_message(warning, E))).\n" % (mod, path))
    loader.append(':- initialization(main, main).')
    loader.append('main :-')
    for mod, pis in CANON.items():
        loader.append("    report(%s, [%s])," % (mod, ', '.join("%s" % p for p in pis)))
    loader.append("    add_synthetic,")
    loader.append("    format(\"synthetic cases~n\"),")
    loader.append("    behaviour_report(ch19, [stack_overflow(201,_), stack_overflow(202,_), stack_overflow(203,_), stack_overflow(204,_), stack_overflow(205,_), frame_regularity(201,_,_), frame_regularity(203,_,_)]),")
    loader.append("    behaviour_report(ch20, [deadlock(critical_section,_,_), deadlock(mutant,_,_), deadlock(any,_,_), deadlock_witness(critical_section,_,_), wait_chain(critical_section,_)]),")
    loader.append("    behaviour_report(ch18, [spiking_thread(_,_), blocked_thread(_,_), frame_regularity(_,_,_), runs([a-f,a-f,b-g,a-f,a-f,b-g,a-f,a-f],_)]),")
    loader.append("    behaviour_report(ch21, [insufficient_memory(_,_,_), handle_leak(_)]),")
    loader.append("    behaviour_report(ch22, [not_my_version(_), unknown_component(_), no_component_symbols(_), hooked_functions(_,_,_), last_error_collection(_)]),")
    loader.append("    halt(0).")
    lp = os.path.join(work, 'equiv.pl')
    with open(lp, 'w') as f:
        f.write('\n'.join(loader) + '\n')
    r = subprocess.run(['swipl', '-q', lp], capture_output=True, text=True, timeout=300, cwd=work)
    out = r.stdout + r.stderr
    print(out)
    # every predicate comparison and every synthetic case is counted; the
    # run passes only if every one of them agrees and the Prolog process
    # exited normally with every expected comparison present
    expected_pis = sum(len(pis) for pis in CANON.values())
    identical = len(re.findall(r'^  \S+ identical/same_answers$', out, re.M))
    agree = len(re.findall(r'^  .*: agree \(\d+ answers\)$', out, re.M))
    other = len(re.findall(r'^  \S+ (?!identical/same_answers$)\S+$', out, re.M)) \
        + len(re.findall(r'DISAGREE', out))
    problems = []
    if r.returncode != 0:
        problems.append('swipl exited with status %d' % r.returncode)
    if identical != expected_pis:
        problems.append('%d of %d predicate comparisons identical/same_answers' % (identical, expected_pis))
    if agree != EXPECTED_SYNTHETIC:
        problems.append('%d of %d synthetic comparisons agree' % (agree, EXPECTED_SYNTHETIC))
    if other:
        problems.append('%d comparisons differ or disagree' % other)
    if ('error(' in out) or ('Warning' in out) or ('ERROR' in out) or ('Traceback' in out):
        problems.append('diagnostics in the output')
    print('EQUIVALENCE SUMMARY: %d of %d predicates identical/same_answers, %d of %d synthetic comparisons agree, %s'
          % (identical, expected_pis, agree, EXPECTED_SYNTHETIC, ('FAIL: ' + '; '.join(problems)) if problems else 'PASS'))
    if not verbose:
        shutil.rmtree(work, ignore_errors=True)
    else:
        print('work dir:', work)
    return 1 if problems else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))

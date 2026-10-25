# Prolog for Software Diagnostics

The code of the book **Prolog for Pattern-Oriented Software Diagnostics:
Logic Programming for Memory Dump, Trace, and Log Analysis** (Dmitry Vostokov,
OpenTask, 2026): every program and every toplevel transcript, the synthetic
artifacts they run on, and the harness that replays the transcripts against
SWI-Prolog and compares the output line by line.

Every transcript in the book was produced by this replay under SWI-Prolog
9.0.4; `sh tools/verify_all.sh` repeats it (33 files, 2,367 checks).

## Layout

| Path | Contents |
|---|---|
| `src/NN-slug.md` | One file per chapter: the chapter's section headings and every fenced code block of the chapter, verbatim, with the prose removed. Program blocks and transcripts appear in the order the book runs them. |
| `src/shared/` | `dump1.pl`, a synthetic user-mode process memory dump as Prolog facts; `trace1.pl`, a synthetic application trace; `patterns_dump.pl`, the module collecting the recognizers of Chapters 18 to 22; `wd.pl`, the Prolog module of the [PrologWinDbg](https://github.com/DumpAnalysis/PrologWinDbg) extension, verbatim, for Chapter 31. |
| `programs/chNN/` | The program blocks of chapter NN as individual `.pl` files, numbered in chapter order (`18-03.pl` is the third program block of Chapter 18); a block the book stores under a name keeps it (`wd_bridge.pl`, `snapshot1.pl`, ...). Each file's header names its chapter and section. |
| `tools/verify.py` | Replays one chapter file: consults its program blocks into a running toplevel under a pseudo-terminal, types its queries, and compares the output with the transcript. |
| `tools/verify_all.sh` | Replays every chapter and runs `tools/equivalence.py`, which checks the shared module against the chapter definitions. |

## Running the code

Load a chapter's programs at the toplevel from the directory that holds the
shared artifacts:

```
$ cd src/shared
$ swipl
?- ['../../programs/ch18/18-01.pl'].
?- ['../../programs/ch18/18-02.pl'].
?- stack_trace(103, Frames).
```

The first block of a chapter consults the artifact it needs (`:- [dump1].`),
which resolves against the working directory.

A chapter's program blocks build on one another in order, and the transcripts
in `src/NN-slug.md` show exactly which blocks were loaded before each query. A
block marked `.fresh` was loaded into a new toplevel.

## Replaying the transcripts

```
$ sh tools/verify_all.sh
...
33 files, 2367 checks, 0 failures
RESULT: PASS (33 files, 2367 checks, 0 failures)
```

The complete output is in `build/verify_run.log`. To replay one chapter:

```
$ python3 tools/verify.py src/18-stack-traces-and-threads.md
PASS src/18-stack-traces-and-threads.md: 74 checks, 0 failures
```

The expected output is that of SWI-Prolog 9.0.4 (the version Ubuntu 24.04
ships). A later version may word an error message or print an answer
differently, and the replay reports each such line as a mismatch; the
difference, not the code, is what changed. The harness needs `swipl` on the
path and Python 3 on a POSIX system, since it drives the toplevel through a
pseudo-terminal.

## Conventions in the chapter files

A fenced block carries the attributes the harness reads:

| Attribute | Meaning |
|---|---|
| `{.prolog .program}` | consulted into the running toplevel |
| `{.prolog .program file=NAME}` | the same, stored under `NAME` so that `consult(NAME)` and `use_module(NAME)` work |
| `{.prolog .query}` | a transcript: lines beginning `?- ` are queries, the lines after each one are its expected output |
| `.fresh` | start a new toplevel before this block |
| `.warn` | consult warnings are expected |
| `{.prolog}` | illustrative only; checked for syntax, not run |
| `text` | debugger output or a session log; not Prolog |

The artifacts are synthetic: `dump1.pl` is modelled on what a Windows debugger
reports for a 64-bit process and `trace1.pl` on an application log, but every
value in them is invented.

## Licence

PolyForm Strict License 1.0.0; see [LICENSE.md](LICENSE.md). `src/shared/wd.pl`
is reproduced from PrologWinDbg under the same licence.

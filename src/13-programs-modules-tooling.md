# Chapter 13. Programs, Modules, Files, and Tooling

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/13-programs-modules-tooling.md`.

## 13.1 Modules

```{.prolog .program file=dumpkb.pl}
:- module(dumpkb,
          [ stack_trace/2,
            top_frame/2,
            thread_modules/2,
            spiking_thread/1,
            blocked_on/2
          ]).

:- [dump1].

%!  stack_trace(+TID, -Frames) is det.
%
%   Frames is the list of frame/5 terms of thread
%   TID in frame order, [] if TID has no frames.
stack_trace(TID, Frames) :-
    frames_from(TID, 0, Frames).

frames_from(TID, N, Frames) :-
    (   frame(TID, N, M, F, O)
    ->  Frames = [frame(TID, N, M, F, O) | Rest],
        succ(N, N1),
        frames_from(TID, N1, Rest)
    ;   Frames = []
    ).

%!  top_frame(?TID, ?Function) is nondet.
%
%   Function is the function of frame 0 of TID.
top_frame(TID, Function) :-
    frame(TID, 0, _, Function, _).

%!  thread_modules(+TID, -Modules) is det.
%
%   Modules is the set of modules on the stack
%   trace of TID, in standard order.
thread_modules(TID, Modules) :-
    stack_trace(TID, Frames),
    maplist(frame_module, Frames, List),
    sort(List, Modules).

frame_module(frame(_, _, M, _, _), M).

%!  spiking_thread(?TID) is nondet.
%
%   TID used at least a quarter of the CPU time
%   of all threads of the dump.
spiking_thread(TID) :-
    aggregate_all(sum(U + K),
                  thread_time(_, U, K), Total),
    thread_time(TID, User, Kernel),
    (User + Kernel) * 4 >= Total.

%!  blocked_on(?TID, ?Owner) is nondet.
%
%   TID waits for a critical section that thread
%   Owner holds.
blocked_on(TID, Owner) :-
    waits_for(TID, critical_section, Addr),
    critical_section(Addr, Owner, _, _),
    Owner =\= 0.
```

```{.prolog .program}
:- use_module(dumpkb).
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.

?- stack_trace(109, _Fs), length(_Fs, N).
N = 7.

?- top_frame(109, F).
F = 'Buffer::Copy'.

?- spiking_thread(T).
T = 102 ;
T = 107 ;
false.

?- blocked_on(T, O).
T = 101,
O = 103 ;
T = 103,
O = 104 ;
T = 104,
O = 103.
```

```{.prolog .query}
?- G = frame(109, 0, M, F, O),
   catch(G, error(E, _), true).
G = frame(109, 0, M, F, O),
E = existence_error(procedure, frame/5).
```

```{.prolog .query}
?- dumpkb:frame(109, 0, M, F, O).
M = dbclient,
F = 'Buffer::Copy',
O = 26.

?- dumpkb:frames_from(105, 2, _Fs),
   length(_Fs, N),
   last(_Fs, frame(_, K, M, F, _)).
N = 2,
K = 3,
M = ntdll,
F = 'RtlUserThreadStart'.
```

```{.prolog .query}
?- module_property(dumpkb, exports(_Es)),
   length(_Es, N).
N = 5.

?- predicate_property(stack_trace(_, _),
   imported_from(M)).
M = dumpkb.

?- predicate_property(append(_, _, _),
   imported_from(M)).
M = lists.

?- predicate_property(dumpkb:frames_from(_, _, _),
   exported).
false.
```

```prolog
:- module(patterns, []).
:- reexport(dumpkb).
:- reexport(tracekb, [time_delta/3]).
```

```{.prolog .query .sitepath}
?- absolute_file_name(library(lists), F,
   [file_type(prolog), access(read)]).
F = '/usr/lib/swi-prolog/library/lists.pl'.
```

### 13.1.1 Meta-Predicates

```{.prolog .program file=closures.pl}
:- module(closures,
          [ show_goal/1,
            show_plain/1,
            frames_where/3
          ]).

:- meta_predicate show_goal(0).
:- meta_predicate frames_where(+, 1, -).

show_goal(G) :- writeln(G).
show_plain(G) :- writeln(G).

%!  frames_where(+TID, :Cond, -Frames) is det.
%
%   Frames are the frames of TID for which the
%   closure Cond succeeds.
frames_where(TID, Cond, Frames) :-
    dumpkb:stack_trace(TID, All),
    include(Cond, All, Frames).
```

```{.prolog .program}
:- use_module(closures).

% in_module(M, Frame): Frame is in module M.
in_module(M, frame(_, _, M, _, _)).
```

```{.prolog .query}
?- show_goal(true).
user:true
true.

?- show_plain(true).
true
true.

?- frames_where(109, in_module(appserver), _Fs),
   maplist([frame(_, N, _, F, _), N-F]>>true,
           _Fs, Pairs).
Pairs = [2-'Session::Fetch', 3-'Worker::Run'].

?- predicate_property(frames_where(_, _, _),
   meta_predicate(Spec)).
Spec = frames_where(+, 1, -).
```

## 13.2 Programs and Scripts

```{.prolog .program file=deltas.pl}
#!/usr/bin/env swipl
% deltas.pl: print the Time Delta anomalies of a
% software trace stored as CSV.

:- use_module(library(main)).
:- use_module(library(option)).
:- use_module(library(csv)).

% stop the collector thread, so that the exit of
% a short run cannot race it (Section 31.1)
:- set_prolog_gc_thread(false).
:- initialization(main, main).

main(Argv) :-
    argv_options(Argv, [File], Options),
    option(threshold(Min), Options, 1.0),
    csv_read_file(File, Rows, [functor(msg)]),
    report_deltas(Rows, Min).

% report_deltas(Rows, Min): print each pair of
% adjacent rows whose time difference is >= Min.
report_deltas([], _).
report_deltas([Row | Rows], Min) :-
    report_deltas(Rows, Row, Min).

report_deltas([], _, _).
report_deltas([Row | Rows], Prev, Min) :-
    Prev = msg(N1, T1, _, _, _),
    Row = msg(N2, T2, Th, C, Tx),
    Delta is T2 - T1,
    (   Delta >= Min
    ->  format("~w -> ~w: ~3f s (~w, ~w)~n",
               [N1, N2, Delta, Th, C]),
        format("    ~w~n", [Tx])
    ;   true
    ),
    report_deltas(Rows, Row, Min).
```

```text
$ swipl deltas.pl trace1.csv
66 -> 67: 4.691 s (109, appserver)
    Request 10 received: GET /session/9/data
$ swipl deltas.pl --threshold=0.7 trace1.csv
10 -> 11: 0.786 s (100, appserver)
    Request 1 received: GET /report/17
38 -> 39: 0.998 s (100, appserver)
    Request 6 received: GET /health
40 -> 41: 0.999 s (100, appserver)
    Request 7 received: GET /health
43 -> 44: 0.998 s (100, appserver)
    Request 8 received: GET /health
45 -> 46: 0.999 s (100, appserver)
    Request 9 received: GET /health
66 -> 67: 4.691 s (109, appserver)
    Request 10 received: GET /session/9/data
$ echo $?
0
```

## 13.3 Reading and Writing Files

```{.prolog .query}
?- open('dump1.pl', read, _S),
   read_term(_S, T1, []),
   read_term(_S, T2, []),
   close(_S).
T1 = (:-discontiguous frame/5),
T2 = process(4120, 'AppServer.exe').
```

```{.prolog .program}
% file_functors(File, Pairs): Pairs lists, in
% standard order, the Name/Arity of each clause
% head in File with its number of clauses.
file_functors(File, Pairs) :-
    setup_call_cleanup(
        open(File, read, S),
        read_functors(S, Fs),
        close(S)),
    msort(Fs, Sorted),
    clumped(Sorted, Pairs).

read_functors(S, Fs) :-
    read_term(S, T, []),
    (   T == end_of_file
    ->  Fs = []
    ;   T = (:- _)
    ->  read_functors(S, Fs)
    ;   functor(T, Name, Arity),
        Fs = [Name/Arity | Rest],
        read_functors(S, Rest)
    ).
```

```{.prolog .query}
?- file_functors('dump1.pl', _Pairs),
   memberchk(frame/5-N, _Pairs),
   length(_Pairs, Kinds).
N = 78,
Kinds = 15.
```

```{.prolog .query}
?- open('notes.txt', write, _S),
   format(_S, "thread ~w~n", [109]),
   format(_S, "code ~16r~n", [0xc0000005]),
   close(_S).
true.

?- open('notes.txt', read, _S),
   read_line_to_string(_S, A),
   read_line_to_string(_S, B),
   read_line_to_string(_S, C),
   close(_S).
A = "thread 109",
B = "code c0000005",
C = end_of_file.

?- read_file_to_string('notes.txt', Str, []).
Str = "thread 109\ncode c0000005\n".
```

## 13.4 CSV, JSON, and Regular Expressions

```{.prolog .program}
:- [trace1].
```

```{.prolog .query}
?- findall(row(N, T, Th, C, Tx),
   msg(N, T, _, Th, C, Tx), _Rows),
   csv_write_file('trace1.csv', _Rows).
true.

?- read_file_to_string('trace1.csv', _Str, []),
   split_string(_Str, "\n", "\r", _Lines),
   nth1(7, _Lines, _L7),
   nth1(14, _Lines, _L14),
   format("~s~n~s~n", [_L7, _L14]).
7,0.215,101,appserver,Worker 101 ready
14,1.048,101,dbclient,"Query end: 1 row, 44 ms"
true.

?- csv_read_file('trace1.csv', _Rows,
   [functor(msg)]),
   length(_Rows, N),
   nth1(14, _Rows, msg(_, T, Th, C, Text)).
N = 71,
T = 1.048,
Th = 101,
C = dbclient,
Text = 'Query end: 1 row, 44 ms'.
```

```{.prolog .program}
:- use_module(library(http/json)).
```

```{.prolog .query}
?- _D = _{thread:109, code:0xc0000005,
          access:"read"},
   open('exception.json', write, _S),
   json_write_dict(_S, _D),
   close(_S),
   read_file_to_string('exception.json', _T, []),
   format("~s~n", [_T]).
{"access":"read", "code":3221225477, "thread":109}
true.

?- open('exception.json', read, _S),
   json_read_dict(_S, D),
   close(_S),
   get_dict(code, D, _Code),
   format("~16r~n", [_Code]).
c0000005
D = _{access:"read", code:3221225477, thread:109}.

?- atom_json_dict('{"tid": 101, "waits": [103]}',
   D, []).
D = _{tid:101, waits:[103]}.
```

```{.prolog .program}
:- use_module(library(pcre)).

% completion(Text, Request, Ms): Text reports the
% completion of Request after Ms milliseconds.
completion(Text, Request, Ms) :-
    re_matchsub("^Request (?<r_I>\\d+) \c
                 completed: (?<s_I>\\d+), \c
                 (?<ms_I>\\d+) ms$",
                Text, Sub, []),
    get_dict(r, Sub, Request),
    get_dict(ms, Sub, Ms).
```

```{.prolog .query}
?- re_match("^Error:", "Error: queue depth 3").
true.

?- re_match("^Error:", "No error here").
false.

?- msg(N, _, _, _, _, Tx), completion(Tx, R, Ms).
N = 17,
Tx = "Request 1 completed: 200, 309 ms",
R = 1,
Ms = 309 ;
N = 58,
Tx = "Request 5 completed: 200, 4300 ms",
R = 5,
Ms = 4300 ;
N = 60,
Tx = "Request 6 completed: 200, 3302 ms",
R = 6,
Ms = 3302 ;
N = 62,
Tx = "Request 7 completed: 200, 2305 ms",
R = 7,
Ms = 2305 ;
N = 64,
Tx = "Request 8 completed: 200, 1307 ms",
R = 8,
Ms = 1307 ;
N = 66,
Tx = "Request 9 completed: 200, 309 ms",
R = 9,
Ms = 309 ;
false.

?- re_foldl([_, C0, C]>>(C is C0 + 1), "\\d+",
   "Request 5 completed: 200, 4300 ms", 0, N, []).
N = 3.
```

## 13.5 Debugging, Assertions, and Unit Tests

```{.prolog .program}
:- use_module(library(debug)).

% deep_thread(TID, Depth): the stack trace of TID
% has Depth frames, more than nine.
deep_thread(TID, Depth) :-
    stack_trace(TID, Frames),
    length(Frames, Depth),
    debug(depth, "thread ~w: ~w frames",
          [TID, Depth]),
    Depth > 9.
```

```{.prolog .query}
?- deep_thread(107, D).
D = 14.

?- debug(depth).
true.

?- deep_thread(107, D).
% thread 107: 14 frames
D = 14.

?- deep_thread(105, D).
% thread 105: 4 frames
false.

?- nodebug(depth).
true.
```

```{.prolog .query}
?- stack_trace(109, _Fs), length(_Fs, N),
   assertion(N > 0).
N = 7.
```

```text
ERROR: Assertion failed: user:(0>0)
  [13] prolog_stack:backtrace(10) at ...
  [12] prolog_debug:assertion_failed(fail,user:(0>0)) at ...
  ...
```

```{.prolog .program}
:- use_module(library(plunit)).
:- set_prolog_flag(verbose, normal).

:- begin_tests(stacks).

test(faulting_frame, true(F == 'Buffer::Copy')) :-
    top_frame(109, F).

test(depth_of_107, true(N == 14)) :-
    stack_trace(107, Frames),
    length(Frames, N).

test(no_such_thread, true(Frames == [])) :-
    stack_trace(999, Frames).

test(pool_threads, all(T == [105, 106])) :-
    top_frame(T, 'NtWaitForWorkViaWorkerFactory').

test(deep_thread_fails, fail) :-
    deep_thread(105, _).

test(top_frame_is_nondet, nondet) :-
    top_frame(_, 'NtWaitForAlertByThreadId').

:- end_tests(stacks).
```

```{.prolog .query}
?- run_tests.
% PL-Unit: stacks ...... passed <...> sec
% All 6 tests passed
true.

?- run_tests(stacks:depth_of_107).
% PL-Unit: stacks:depth_of_107 . passed <...> sec
% test passed
true.
```

```{.prolog .program}
:- begin_tests(broken).

test(wrong_depth, true(N == 7)) :-
    stack_trace(107, Frames),
    length(Frames, N).

test(wrong_type) :-
    _ is foo + 1.

test(bottom_frame, nondet) :-
    top_frame(_, 'RtlUserThreadStart').

:- end_tests(broken).
```

```{.prolog .query}
?- run_tests(broken).
% PL-Unit: broken 
ERROR: <...>
<...>test wrong_depth: wrong answer <...>
ERROR:     Expected: 7
ERROR:     Got:      14
ERROR: <...>
<...>test wrong_type: received error: <...>
ERROR: <...>
<...>test bottom_frame: failed
...
% 3 tests failed
% 0 tests passed
false.
```

## 13.6 Timing, Indexing, and Inspection

```{.prolog .program .fresh}
:- use_module(dumpkb).
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.

?- time(stack_trace(107, _Fs)).
% <...> inferences, <...> CPU in <...>
true.

?- statistics(inferences, _I0),
   stack_trace(107, _Fs),
   statistics(inferences, _I1),
   I is _I1 - _I0.
I = 47.
```

```{.prolog .query}
?- jiti_list(dumpkb:frame/5).
Predicate <...> Flags
<...>
dumpkb:frame/5 <...>
true.
```

```{.prolog .query}
?- dumpkb:frame(T, N, _, 'Worker::Run', _).
T = 101,
N = 6 ;
T = 102,
N = 3 ;
T = 103,
N = 6 ;
T = 107,
N = 10 ;
T = 109,
N = 3.

?- jiti_list(dumpkb:frame/5).
Predicate <...> Flags
<...>
dumpkb:frame/5 <...>
<...>4 <...>
true.
```

```{.prolog .query}
?- listing(dumpkb:top_frame).
top_frame(TID, Function) :-
    frame(TID, 0, _, Function, _).

true.

?- portray_clause(frame(109, 0, dbclient,
   'Buffer::Copy', 0x1a)).
frame(109, 0, dbclient, 'Buffer::Copy', 26).
true.
```

## 13.7 Diagnostic Use

```{.prolog .program}
:- use_module(library(plunit)).

:- begin_tests(patterns).

test(spiking_threads, all(T == [102, 107])) :-
    spiking_thread(T).

test(main_thread_not_spiking, fail) :-
    spiking_thread(100).

test(deadlock_pair, true(O == 104)) :-
    blocked_on(103, O).

test(blocked_threads, all(T-O == [101-103,
                                  103-104,
                                  104-103])) :-
    blocked_on(T, O).

test(faulting_modules, true(Ms == [appserver,
                                  dbclient,
                                  kernel32,
                                  ntdll,
                                  ucrtbase])) :-
    thread_modules(109, Ms).

test(idle_pool_thread, true(Ms == [kernel32,
                                  ntdll])) :-
    thread_modules(105, Ms).

:- end_tests(patterns).
```

```{.prolog .query}
?- set_prolog_flag(verbose, normal).
true.

?- run_tests(patterns).
% PL-Unit: patterns ...... passed <...> sec
% All 6 tests passed
true.
```

```{.prolog .program}
:- consult(deltas).
```

```{.prolog .query}
?- csv_read_file('trace1.csv', _Rows,
   [functor(msg)]),
   report_deltas(_Rows, 2.0).
66 -> 67: 4.691 s (109, appserver)
    Request 10 received: GET /session/9/data
true.
```

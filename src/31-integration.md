# Chapter 31. Integration: Scripts, Embedding, and Debugger Extensions

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/31-integration.md`.

## 31.1 Command-Line Tools

```{.prolog .program file=gaps.pl}
:- use_module(library(main)).
:- set_prolog_gc_thread(false).
:- initialization(main, main).

% opt_type(Opt, Name, Type)
opt_type(threshold, threshold, float).
opt_type(t, threshold, float).
opt_type(csv, csv, boolean).

opt_help(threshold, "Minimum gap in seconds").
opt_help(csv, "Comma-separated output").
opt_help(help(usage), " -- trace.pl [options]").

main(Argv) :-
    argv_options(Argv, [File], Options),
    option(threshold(Min), Options, 1.0),
    option(csv(CSV), Options, false),
    consult(File),
    forall(( gap(N1, N2, Gap), Gap > Min ),
           report(CSV, N1, N2, Gap)).

% gap(?N1, -N2, -Gap): time between consecutive
% messages.
gap(N1, N2, Gap) :-
    msg(N1, T1, _, _, _, _),
    N2 is N1 + 1,
    msg(N2, T2, _, _, _, _),
    Gap is T2 - T1.

report(false, N1, N2, Gap) :-
    format("~d -> ~d: ~3f s~n", [N1, N2, Gap]).
report(true, N1, N2, Gap) :-
    format("~d,~d,~3f~n", [N1, N2, Gap]).
```

```{.prolog .query}
?- argv_options(['trace1.pl', '--threshold=0.5'],
                Positional, Options).
Positional = ['trace1.pl'],
Options = [threshold(0.5)].

?- argv_options(['trace1.pl', '-t', '0.5',
                 '--no-csv'],
                Positional, Options).
Positional = ['trace1.pl'],
Options = [threshold(0.5), csv(false)].

?- shell('swipl gaps.pl -- trace1.pl -t 0.5').
10 -> 11: 0.786 s
38 -> 39: 0.998 s
40 -> 41: 0.999 s
43 -> 44: 0.998 s
45 -> 46: 0.999 s
66 -> 67: 4.691 s
true.

?- shell('swipl gaps.pl -- trace1.pl -t 2 --csv').
66,67,4.691
true.
```

```{.prolog .query}
?- shell('swipl gaps.pl -- trace1.pl -t abc',
         Status).
ERROR: Option -t requires an argument<...>
Status = 1.

?- shell('stty cols 80; swipl gaps.pl --help').
Usage: swipl gaps.pl -- trace.pl [options]

Options:
-h, -?, --help<...>
-t FLOAT, --threshold=FLOAT Minimum gap in seconds
--csv                       Comma-separated output
true.
```

## 31.2 JSON

```{.prolog .program}
:- use_module(library(http/json)).
:- [dump1].
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.

?- json_write_dict(current_output,
       _{pattern:"Spiking Thread",
         threads:[102]}).
{"pattern":"Spiking Thread", "threads": [102 ]}
true.

?- json_write_dict(current_output,
       _{pattern:"Spiking Thread", threads:[102],
         exception:null, verified:true},
       [width(20)]).
{
  "exception":null,
  "pattern":"Spiking Thread",
  "threads": [102 ],
  "verified":true
}
true.

?- atom_json_dict('{"hypothesis": "deadlock(103)",
                    "id": 7}', D, []).
D = _{hypothesis:"deadlock(103)", id:7}.

?- atom_json_dict('{"id": 7}', _D, []),
   get_dict(id, _D, Id).
Id = 7.
```

```{.prolog .query}
?- setup_call_cleanup(
       open('finding.json', write, _S),
       json_write_dict(_S, _{tid:109,
                            code:0xc0000005}),
       close(_S)).
true.

?- setup_call_cleanup(
       open('finding.json', read, _S),
       json_read_dict(_S, D),
       close(_S)).
D = _{code:3221225477, tid:109}.
```

## 31.3 CSV

```{.prolog .program}
:- use_module(library(csv)).

% thread_rows(-Rows): CPU times as CSV rows with a
% header row.
thread_rows([Header|Rows]) :-
    Header = row(tid, user_ms, kernel_ms),
    findall(row(T, U, K), thread_time(T, U, K),
            Rows).
```

```{.prolog .query}
?- thread_rows(_Rows),
   csv_write_file('threads.csv', _Rows).
true.

?- shell('head -3 threads.csv').
tid,user_ms,kernel_ms
100,120,40
101,15,5
true.

?- csv_read_file('threads.csv', _Rows),
   length(_Rows, N),
   _Rows = [Header|_].
N = 11,
Header = row(tid, user_ms, kernel_ms).

?- csv_read_file_row('threads.csv', row(T, U, K),
                     [line(L)]),
   integer(U),
   U + K > 5000.
T = 102,
U = 8450,
K = 1230,
L = 4 ;
false.
```

## 31.4 An HTTP Service

```prolog
:- use_module(library(http/http_server)).
:- use_module(library(http/http_json)).
:- [dump1].
:- use_module(patterns_dump).

% POST /check with a request body such as
% {"hypothesis": "deadlock(critical_section, C)"}
:- http_handler(root(check), check_handler,
                [method(post)]).

check_handler(Request) :-
    http_read_json_dict(Request, In),
    get_dict(hypothesis, In, Text),
    check_hypothesis(Text, Verdict),
    verdict_dict(Text, Verdict, Out),
    reply_json_dict(Out).

% serve: listen on the loopback interface, port
% 8080, and wait forever.
serve :-
    http_server([port(localhost:8080)]),
    thread_get_message(_).
```

## 31.5 Embedding the Engine in C

```text
#include <SWI-Prolog.h>
#include <stdio.h>

int main(int argc, char **argv)
{ char *av[] = { argv[0], "-q", NULL };

  if ( !PL_initialise(2, av) )
    PL_halt(1);

  { term_t goal = PL_new_term_ref();
    PL_chars_to_term("[dump1], use_module(patterns_dump)",
                     goal);
    if ( !PL_call(goal, NULL) )
      fprintf(stderr, "loading failed\n");
  }
  ...
```

```text
  { predicate_t p = PL_predicate("spiking_thread", 1, "user");
    term_t args = PL_new_term_refs(1);
    qid_t q = PL_open_query(NULL, PL_Q_NORMAL, p, args);

    while ( PL_next_solution(q) )
    { int tid;

      if ( PL_get_integer(args, &tid) )
        printf("Spiking thread %d\n", tid);
    }
    PL_close_query(q);
  }

  PL_halt(0);
}
```

```text
static foreign_t
pl_dbg_execute(term_t cmd, term_t out)
{ char *s;

  if ( !PL_get_chars(cmd, &s, CVT_ATOM|CVT_STRING|REP_UTF8) )
    return PL_type_error("text", cmd);
  const char *reply = host_execute(s);   /* the host's API */
  if ( !reply )
    return FALSE;
  return PL_unify_atom_chars(out, reply);
}

install_t
install_dbgpl(void)
{ PL_register_foreign("dbg_execute", 2, pl_dbg_execute, 0);
}
```

## 31.6 A Debugger Extension: A Design

```prolog
% Illustrative: the Prolog side of the extension.
% dbg_frame/5 and dbg_execute/2 are foreign.
:- dynamic cached_frame/5, frames_complete/1.

frame(TID, N, M, F, O) :-
    (   frames_complete(TID)
    ->  true
    ;   fetch_frames(TID)
    ),
    cached_frame(TID, N, M, F, O).

fetch_frames(TID) :-
    forall(dbg_frame(TID, N, M, F, O),
           assertz(cached_frame(TID, N, M, F,
                                O))),
    assertz(frames_complete(TID)).
```

## 31.7 PrologWinDbg: The Extension as Built

```text
0:000> .load "D:/.../dist/x64/prolog.dll"
0:000> !prolog.runtime "D:/.../swipl-x64/bin/swipl.exe"
[prolog] Runtime set to D:\a\_temp\swipl-x64\bin\swipl.exe
0:000> !prolog.info
[prolog] 0.2.0 / protocol 1; extension=amd64;
  SWI-Prolog 10.1.18; worker running
0:000> !prolog.consult "D:/.../examples/patterns.pl"
[prolog] ok; 0 answer(s). File consulted
0:000> !prolog.eval X is 6*7, X=42, writeln('PD_ARITHMETIC_OK').
PD_ARITHMETIC_OK
bindings(['X'=42],[])
[prolog] ok; 1 answer(s). Search exhausted for the captured
  evidence
0:001> !prolog.query wd:current_snapshot(S),
  findall(T,wd:thread(S,T),Ts), length(Ts,N), N>=3,
  writeln('PD_THREADS_OK').
*** WARNING: Unable to verify checksum for prologdbg_target.exe
[prolog] Snapshot 4
PD_THREADS_OK
bindings(['S'=4,'T'=_155800,'Ts'=[0,1,2,3,4,5],'N'=6],[])
[prolog] ok; 1 answer(s). Search exhausted for the captured
  evidence
0:001> !prolog.query wd:current_snapshot(S),
  once(patterns:shared_function(S,A,B,prologdbg_target,
                                'WaitForRelease')),
  writeln('PD_STACKS_OK').
[prolog] Snapshot 7
PD_STACKS_OK
bindings(['S'=7,'A'=4,'B'=5],[])
[prolog] ok; 1 answer(s). Search exhausted for the captured
  evidence
0:001> !prolog.limits 100 100 128 10000000
[prolog] 100 ms; 100 answers; 128 frames/thread;
  10000000 inferences
0:001> !prolog.eval sleep(2).
[prolog] timeout; 0 answer(s). Time budget exhausted; results
  are incomplete
```

### 31.7.1 The Two Designs Compared

### 31.7.2 The Schema of Part II over a Snapshot

```{.prolog .program .fresh file=wd_bridge.pl}
% wd_bridge.pl -- the schema of Part II over the
% snapshot of a PrologWinDbg query. Loaded into
% user beside patterns_dump, whose recognizers
% call user:frame/5 and the other relations.
:- use_module(wd, [current_snapshot/1]).

% The relations the extension does not capture
% in version 0.2.0: declared, and empty, so that
% a recognizer fails on them rather than raising
% an existence error, and so that their coverage
% is unknown (Section 15.5), never complete.
:- dynamic process/2, module_info/3,
           thread_time/3, thread_state/2,
           exception_record/3, exception_info/3,
           critical_section/4, waits_for/3,
           handle_count/3, heap/4, last_error/2,
           hooked/3.

% thread(TID, PID): every thread the engine
% enumerated, by its Windows thread identifier,
% in the process the snapshot was taken from.
thread(TID, PID) :-
    current_snapshot(S),
    wd:target(S, _, PID, _),
    wd:thread_id(S, _, TID).

% frame(TID, N, Module, Function, Offset): a
% captured frame with its symbol, the module name
% lowercased as Section 15.4 requires; a frame
% whose address has no symbol is recorded as
% frame(TID, N, none, 'Unknown', 0), as there.
frame(TID, N, Module, Function, Offset) :-
    current_snapshot(S),
    wd:thread_id(S, T, TID),
    wd:stack_frame(S, T, N, IP),
    (   wd:symbol(S, IP, M0, Function, Offset)
    ->  downcase_atom(M0, Module)
    ;   Module = none, Function = 'Unknown',
        Offset = 0
    ).

% module(Name, Base, Size): a loaded module.
module(Name, Base, Size) :-
    current_snapshot(S),
    wd:module(S, M0, Base, Size),
    downcase_atom(M0, Name).

% stack_coverage(TID, Status): the coverage of
% frame/5 for one thread, in the terms of Section
% 15.5. The engine certifies no unwind, so the
% status is never complete: a captured prefix is
% incomplete, with the reason the engine gives,
% and a thread the snapshot does not hold is
% unknown.
stack_coverage(TID, Status) :-
    current_snapshot(S),
    (   wd:thread_id(S, T, TID),
        wd:coverage(S, stack(T), C)
    ->  (   C = captured_prefix(N, Why)
        ->  Status = incomplete([prefix(N, Why)])
        ;   Status = incomplete([C])
        )
    ;   Status = unknown
    ).
```

```{.prolog .program file=snapshot1.pl}
% sample_snapshot(Facts): a snapshot shaped as the
% extension sends it, for thread 102 of dump1.pl
% as the engine would capture it: engine thread
% 2, the seven frames, the symbols of their
% addresses, and the coverage statuses.
sample_snapshot(
    [ target(1, dump, 4120, 8),
      architecture(1, amd64),
      coverage(1, threads, enumerated(1)),
      thread(1, 2),
      thread_id(1, 2, 102),
      coverage(1, stack(2),
          captured_prefix(7, unverified_end)),
      stack_frame(1, 2, 0, 0x7ffb_8e41_1a3e),
      stack_frame(1, 2, 1, 0x7ffb_8e41_209a),
      stack_frame(1, 2, 2, 0x7ffb_8e45_0214),
      stack_frame(1, 2, 3, 0x7ff6_1d11_2120),
      stack_frame(1, 2, 4, 0x7ffb_ae51_8042),
      stack_frame(1, 2, 5, 0x7ffb_b1c1_7614),
      stack_frame(1, 2, 6, 0x7ffb_b2a5_2a21),
      symbol(1, 0x7ffb_8e41_1a3e, 'ReportEngine',
             'Table::Find', 0x3e),
      symbol(1, 0x7ffb_8e41_209a, 'ReportEngine',
             'Table::Insert', 0x9a),
      symbol(1, 0x7ffb_8e45_0214, 'ReportEngine',
             'Report::Build', 0x214),
      symbol(1, 0x7ff6_1d11_2120, 'AppServer',
             'Worker::Run', 0x120),
      symbol(1, 0x7ffb_ae51_8042, ucrtbase,
             'thread_start<...>', 0x42),
      symbol(1, 0x7ffb_b1c1_7614, kernel32,
             'BaseThreadInitThunk', 0x14),
      symbol(1, 0x7ffb_b2a5_2a21, ntdll,
             'RtlUserThreadStart', 0x21),
      coverage(1, modules, enumerated(3)),
      module(1, 'AppServer', 0x7ff6_1d10_0000,
             0x3c000),
      module(1, 'ReportEngine', 0x7ffb_8e40_0000,
             0x1a2000),
      module(1, ntdll, 0x7ffb_b2a0_0000, 0x1f8000)
    ]).
```

```{.prolog .query}
?- use_module(patterns_dump).
true.

?- set_prolog_flag(toplevel_print_anon, false).
true.

?- sample_snapshot(_Fs),
   wd:install_snapshot(1, _Fs).
true.

?- wd:current_snapshot(S),
   wd:target(S, Kind, PID, _),
   wd:architecture(S, Arch).
S = 1,
Kind = dump,
PID = 4120,
Arch = amd64.

?- thread(T, P).
T = 102,
P = 4120.

?- frame(102, N, M, F, O).
N = 0,
M = reportengine,
F = 'Table::Find',
O = 62 ;
N = 1,
M = reportengine,
F = 'Table::Insert',
O = 154 ;
N = 2,
M = reportengine,
F = 'Report::Build',
O = 532 ;
N = 3,
M = appserver,
F = 'Worker::Run',
O = 288 ;
N = 4,
M = ucrtbase,
F = 'thread_start<...>',
O = 66 ;
N = 5,
M = kernel32,
F = 'BaseThreadInitThunk',
O = 20 ;
N = 6,
M = ntdll,
F = 'RtlUserThreadStart',
O = 33.

?- stack_trace_signature(102, _Sig),
   forall(member(M-F, _Sig), ( print(M-F), nl )).
reportengine-'Table::Find'
reportengine-'Table::Insert'
reportengine-'Report::Build'
appserver-'Worker::Run'
ucrtbase-'thread_start<...>'
kernel32-'BaseThreadInitThunk'
ntdll-'RtlUserThreadStart'
true.

?- module(Name, Base, Size).
Name = appserver,
Base = 140695026270208,
Size = 245760 ;
Name = reportengine,
Base = 140718400077824,
Size = 1712128 ;
Name = ntdll,
Base = 140719010349056,
Size = 2064384.

?- stack_coverage(102, S1),
   stack_coverage(103, S2).
S1 = incomplete([prefix(7, unverified_end)]),
S2 = unknown.

?- \+ frame(103, _, _, _, _).
true.

?- thread_time(102, _, _).
false.

?- catch(wd:install_snapshot(2, [(:- halt)]),
         error(E, _), true).
E = domain_error(snapshot_fact, (:-halt)).
```

```{.prolog .program file=magic.pl}
% inspect_magic(S, Address, Verdict): the example
% rule of the extension's distribution, verbatim:
% a three-way verdict on eight bytes, and never a
% bare failure.
inspect_magic(S,Address,Verdict) :-
    wd:memory(S,Address,8,Result),
    ( Result = ok([80,82,79,76,79,71,68,66])
      -> Verdict=matched(prologdb,Address)
    ; Result = ok(Bytes)
      -> Verdict=mismatch(Bytes)
    ; Verdict=inconclusive(Result) ).

% What the DLL would answer three READ requests
% with: a full read, a short read at a page edge,
% and a failed one. The hook is the module's own
% extension point; the worker binds it to the
% pipe.
:- multifile wd:memory_provider/4.
wd:memory_provider(1, 0x7ff6_1d13_a000, 8,
    ok([80,82,79,76,79,71,68,66])).
wd:memory_provider(1, 0x7ff6_1d13_aff8, 8,
    partial([80,82,79,76], 8,
            "HRESULT 0x0; requested 8, read 4")).
wd:memory_provider(1, 0x10, 8,
    unavailable("HRESULT 0x8000FFFF")).
```

```{.prolog .query}
?- inspect_magic(1, 0x7ff6_1d13_a000, V).
V = matched(prologdb, 140695026507776).

?- inspect_magic(1, 0x7ff6_1d13_aff8, _V),
   _V = inconclusive(partial(Bs, N, _Reason)),
   sub_string(_Reason, 0, 11, _, Code).
Bs = [80, 82, 79, 76],
N = 8,
Code = "HRESULT 0x0".

?- inspect_magic(1, 0x10, inconclusive(V)).
V = unavailable("HRESULT 0x8000FFFF").

?- inspect_magic(1, 0x20, V).
V = inconclusive(unavailable(no_memory_provider)).

?- catch(wd:bytes(1, 0x7ff6_1d13_aff8, 8, _),
         error(incomplete_memory(A, L, _R), _),
         true),
   functor(_R, Shape, _).
A = 140695026511864,
L = 8,
Shape = partial.
```

```{.prolog .program file=snapshot2.pl}
% two_thread_snapshot(Facts): two threads with one
% captured frame each, for the regression case.
two_thread_snapshot(
    [ target(2, dump, 4120, 8),
      architecture(2, amd64),
      coverage(2, threads, enumerated(2)),
      thread(2, 2), thread_id(2, 2, 102),
      thread(2, 3), thread_id(2, 3, 105),
      coverage(2, stack(2),
          captured_prefix(1, frame_limit)),
      coverage(2, stack(3),
          captured_prefix(1, frame_limit)),
      stack_frame(2, 2, 0, 0x7ffb_8e41_1a3e),
      stack_frame(2, 3, 0, 0x7ff6_1d11_3b10),
      symbol(2, 0x7ffb_8e41_1a3e, 'ReportEngine',
             'Table::Find', 0x3e),
      symbol(2, 0x7ff6_1d11_3b10, 'AppServer',
             'Idle::Wait', 0x10),
      coverage(2, modules, enumerated(0))
    ]).
```

```{.prolog .query}
?- two_thread_snapshot(_Fs),
   wd:install_snapshot(2, _Fs).
true.

?- stack_trace_signature(T, _Sig),
   length(_Sig, N).
N = 2.

?- thread(T, _), stack_trace_signature(T, Sig).
T = 102,
Sig = [reportengine-'Table::Find'] ;
T = 105,
Sig = [appserver-'Idle::Wait'].
```

```text
!prolog.consult "C:/book/patterns_dump.pl"
!prolog.consult "C:/book/wd_bridge.pl"
!prolog.query thread(T, _), stack_trace_signature(T, Sig).
!prolog.query frame_regularity(T, Run, N).
```

## 31.8 The Machine Query Interface

```{.prolog .query}
?- use_module(library(mqi)).
true.

?- mqi_version(Major, Minor).
Major = 1,
Minor = 0.
```

## 31.9 Prolog as a Verifier for LLM-Based Agents

```{.prolog .program .fresh}
:- [dump1].
:- use_module(patterns_dump).
:- use_module(library(http/json)).
:- use_module(library(sandbox)).

% prove(+Module, +Goal, -Facts): Goal, called in
% Module, has a proof that used the facts Facts.
prove(_, true, []).
prove(M, (A, B), Facts) :-
    prove(M, A, FA),
    prove(M, B, FB),
    append(FA, FB, Facts).
prove(M, (If -> Then ; Else), Facts) :-
    (   prove(M, If, FI)
    ->  prove(M, Then, FT),
        append(FI, FT, Facts)
    ;   prove(M, Else, Facts)
    ).
prove(M, (A ; B), Facts) :-
    A \= (_ -> _),
    (   prove(M, A, Facts)
    ;   prove(M, B, Facts)
    ).
prove(M, \+ A, []) :-
    \+ prove(M, A, _).
prove(M, once(A), Facts) :-
    once(prove(M, A, Facts)).
prove(M, findall(T, G, L), Facts) :-
    findall(T-F, prove(M, G, F), Pairs),
    pairs_keys_values(Pairs, L, Lists),
    append(Lists, Facts).
prove(M, bagof(T, G, L), Facts) :-
    bagof(T-F, prove(M, G, F), Pairs),
    pairs_keys_values(Pairs, L, Lists),
    append(Lists, Facts).
prove(M, aggregate_all(Spec, G, R), Facts) :-
    findall(Spec-F, prove(M, G, F), Pairs),
    pairs_keys_values(Pairs, Specs, Lists),
    aggregate_all(Spec, member(Spec, Specs), R),
    append(Lists, Facts).
prove(_, M:G, Facts) :-
    prove(M, G, Facts).
prove(M, G, Facts) :-
    \+ construct(G),
    (   system_goal(M:G)
    ->  call(M:G),
        Facts = []
    ;   definition_module(M:G, DefM),
        clause(DefM:G, Body),
        (   Body == true
        ->  fact_leaves(DefM, G, Facts)
        ;   prove(DefM, Body, Facts)
        )
    ).

% construct(@Goal): a goal that prove/3 handles by
% a clause of its own.
construct(true).
construct((_, _)).
construct((_ ; _)).
construct(\+ _).
construct(once(_)).
construct(findall(_, _, _)).
construct(bagof(_, _, _)).
construct(aggregate_all(_, _, _)).
construct(_:_).

% system_goal(+Goal): a built-in or a predicate of
% a library module, executed and not interpreted.
system_goal(G) :-
    predicate_property(G, built_in).
system_goal(G) :-
    predicate_property(G, imported_from(Lib)),
    module_property(Lib, class(library)).

% definition_module(+Goal, -Module): Module holds
% the clauses of the predicate of Goal.
definition_module(M:G, DefM) :-
    (   predicate_property(M:G,
                           imported_from(DefM))
    ->  true
    ;   DefM = M
    ).

% fact_leaves(+Module, +Fact, -Facts): Facts is
% [Fact] as a goal that user can call when Fact
% belongs to a relation defined by facts alone,
% and [] for the base case of a recursive
% predicate.
fact_leaves(M, Fact, Facts) :-
    (   \+ predicate_property(M:Fact,
                              number_of_rules(0))
    ->  Facts = []
    ;   predicate_property(user:Fact, visible)
    ->  Facts = [Fact]
    ;   Facts = [M:Fact]
    ).
```

```{.prolog .program}
% supported(@Goal, -Subgoals): Goal is a control
% construct of the vocabulary over Subgoals.
supported((A, B), [A, B]).
supported((A ; B), [A, B]).
supported(\+ A, [A]).
supported(once(A), [A]).
supported(findall(_, G, _), [G]).
supported(aggregate_all(_, G, _), [G]).

% comparison(@Goal): an arithmetic comparison.
comparison(_ < _).
comparison(_ > _).
comparison(_ =< _).
comparison(_ >= _).
comparison(_ =:= _).
comparison(_ =\= _).

% admitted(@Goal): Goal is in the vocabulary: a
% supported construct over admitted goals, a
% comparison, or an export of patterns_dump.
admitted(Goal) :-
    callable(Goal),
    Goal \= _:_,
    (   supported(Goal, Subgoals)
    ->  maplist(admitted, Subgoals)
    ;   comparison(Goal)
    ->  true
    ;   predicate_property(Goal,
                imported_from(patterns_dump))
    ).

% unsupported(@Goal, -Leaf): Goal is not admitted
% and Leaf is its leftmost subgoal that is not.
unsupported(Goal, Leaf) :-
    (   callable(Goal),
        supported(Goal, Subgoals),
        member(Sub, Subgoals),
        \+ admitted(Sub)
    ->  unsupported(Sub, Leaf)
    ;   Leaf = Goal
    ).
```

```{.prolog .program}
% check_hypothesis(+Text, -Verdict): the verdict
% on the hypothesis Text under the default limits.
check_hypothesis(Text, Verdict) :-
    check_hypothesis(Text, [], Verdict).

% check_hypothesis(+Text, +Options, -Verdict):
% Verdict is proved(Answers), not_proved,
% incomplete(Reason, Answers), or rejected(Why);
% an answer is Bindings-Facts. Options: chars(N),
% answers(N), inferences(N).
check_hypothesis(Text, Options, Verdict) :-
    catch(verify(Text, Options, Verdict),
          error(Why, _),
          Verdict = rejected(Why)).

verify(Text, Options, Verdict) :-
    option(chars(MaxChars), Options, 200),
    string_length(Text, Length),
    (   Length > MaxChars
    ->  Verdict = rejected(input_limit(MaxChars))
    ;   term_string(Goal, Text,
                    [variable_names(Names)]),
        must_be(callable, Goal),
        verify(Goal, Names, Options, Verdict)
    ).

% verify(+Goal, +Names, +Options, -Verdict): the
% verdict on the parsed goal; Names are the
% agent's variable names.
verify(Goal, Names, Options, Verdict) :-
    (   admitted(Goal)
    ->  safe_goal(Goal),
        collect(Goal, Names, Options, Verdict)
    ;   unsupported(Goal, Leaf),
        maplist(name_variable, Names),
        Verdict = rejected(unsupported(Leaf))
    ).

% name_variable(+Binding): bind the variable of a
% Name = Var pair so that it prints as Name.
name_variable(Name = Var) :-
    Var = '$VAR'(Name).

% collect(+Goal, +Names, +Options, -Verdict): the
% answers of Goal with their facts, within the
% limits on answers and inferences.
collect(Goal, Names, Options, Verdict) :-
    option(answers(MaxA), Options, 10),
    option(inferences(MaxI), Options, 1_000_000),
    Chunk is MaxA + 1,
    call_with_inference_limit(
        once(findnsols(Chunk, Names-Facts,
                       answer(Goal, Facts),
                       Found)),
        MaxI, Result),
    (   Result == inference_limit_exceeded
    ->  Reason = inference_limit(MaxI),
        Verdict = incomplete(Reason, [])
    ;   length(Found, N),
        N > MaxA
    ->  length(Answers, MaxA),
        append(Answers, _, Found),
        Reason = answer_limit(MaxA),
        Verdict = incomplete(Reason, Answers)
    ;   Found == []
    ->  Verdict = not_proved
    ;   Verdict = proved(Found)
    ).

% answer(+Goal, -Facts): one proof of Goal, called
% in user, with its facts, each once.
answer(Goal, Facts) :-
    prove(user, Goal, Facts0),
    list_to_set(Facts0, Facts).
```

```{.prolog .program}
% print_verdict(+Text): the verdict, one line per
% binding and per fact.
print_verdict(Text) :-
    check_hypothesis(Text, Verdict),
    format("~s: ", [Text]),
    (   Verdict = proved(Answers)
    ->  length(Answers, N),
        format("proved, ~d answer(s)~n", [N]),
        print_answers(Answers)
    ;   Verdict = incomplete(Reason, Answers)
    ->  length(Answers, N),
        format("incomplete (~q), ~d answer(s)~n",
               [Reason, N]),
        print_answers(Answers)
    ;   format("~q~n", [Verdict])
    ).

print_answers(Answers) :-
    forall(member(Names-Facts, Answers),
           print_answer(Names, Facts)).

print_answer(Names, Facts) :-
    forall(member(N = X, Names),
           format("  ~a = ~q~n", [N, X])),
    forall(member(F, Facts),
           format("  ~q~n", [F])).
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.

?- print_verdict("deadlock(critical_section, C)").
deadlock(critical_section, C): proved, 1 answer(s)
  C = [103,104]
  waits_for(103,critical_section,140695026508096)
  critical_section(140695026508096,104,1,1)
  waits_for(104,critical_section,140695026507968)
  critical_section(140695026507968,103,2,1)
true.

?- print_verdict("spiking_thread(107)").
spiking_thread(107): proved, 1 answer(s)
  thread_time(107,3200,900)
  thread_time(100,120,40)
  thread_time(101,15,5)
  thread_time(102,8450,1230)
  thread_time(103,30,10)
  thread_time(104,25,10)
  thread_time(105,20,5)
  thread_time(106,10,5)
  thread_time(108,0,0)
  thread_time(109,40,20)
  threshold(spiking_share,25)
true.

?- print_verdict("spiking_thread(105)").
spiking_thread(105): not_proved
true.

?- print_verdict("blocked_thread(102)").
blocked_thread(102): not_proved
true.

?- check_hypothesis("spiking_thread(T)",
                    proved(_As)),
   pairs_keys(_As, Bindings).
Bindings = [['T'=102], ['T'=107]].

?- print_verdict("handle_leak(T)").
handle_leak(T): proved, 1 answer(s)
  T = event
  handle_count(4120,event,12040)
  threshold(handle_type_count,5000)
true.
```

```{.prolog .query}
?- _T1 = "deadlock(critical_section, C)",
   _T2 = "once(deadlock(critical_section, C))",
   check_hypothesis(_T1, proved([_-_Direct])),
   check_hypothesis(_T2, proved([_-_Once])),
   _Direct == _Once,
   length(_Direct, N).
N = 4.

?- _T = "findall(C, deadlock(any, C), L)",
   check_hypothesis(_T, proved([Bs-_Facts])),
   length(_Facts, N).
Bs = ['C'=_, 'L'=[[103, 104]]],
N = 4.

?- _T = "aggregate_all(count, waits(_, _, _), N)",
   check_hypothesis(_T, proved([Bs-_Facts])),
   length(_Facts, K).
Bs = ['N'=3],
K = 3.

?- check_hypothesis("\\+ deadlock(mutant, C)", V).
V = proved([['C'=_]-[]]).
```

```{.prolog .query}
?- check_hypothesis("deadlock(103", V).
V = rejected(syntax_error(operator_expected)).

?- check_hypothesis("42", V).
V = rejected(type_error(callable, 42)).

?- check_hypothesis("length(L, N)", V).
V = rejected(unsupported(length(L, N))).

?- check_hypothesis("between(1, inf, X)", V).
V = rejected(unsupported(between(1, inf, X))).

?- check_hypothesis("X = f(a)", V).
V = rejected(unsupported(X=f(a))).

?- _T = "spiking_thread(T), shell('rm -rf /')",
   check_hypothesis(_T, V).
V = rejected(unsupported(shell('rm -rf /'))).

?- _T = "forall(spiking_thread(T), T > 100)",
   check_hypothesis(_T, rejected(unsupported(G))).
G = forall(spiking_thread(T), T>100).

?- check_hypothesis("hidden_exception(109)", V).
V = rejected(unsupported(hidden_exception(109))).

?- check_hypothesis("deadlock(bogus, C)",
       rejected(type_error(oneof(_), Culprit))).
Culprit = bogus.
```

```{.prolog .query}
?- check_hypothesis("no_component_symbols(M)",
                    [answers(2)],
                    incomplete(Reason, _Answers)),
   pairs_keys(_Answers, Bindings).
Reason = answer_limit(2),
Bindings = [['M'=dbclient], ['M'=cachelib]].

?- check_hypothesis("deadlock(any, C)",
                    [inferences(100)], V).
V = incomplete(inference_limit(100), []).

?- collect(length(L, N), ['L'=L, 'N'=N],
           [answers(3)], incomplete(R, _As)),
   length(_As, K).
R = answer_limit(3),
K = 3.

?- collect(between(1, inf, X), ['X'=X],
           [answers(1000), inferences(500)], V).
V = incomplete(inference_limit(500), []).

?- check_hypothesis("spiking_thread(T)",
                    [chars(10)], V).
V = rejected(input_limit(10)).
```

```{.prolog .program}
% verdict_dict(+Text, +Verdict, -Dict): JSON-ready
% form of a verdict.
verdict_dict(Text, Verdict, Dict) :-
    (   Verdict = proved(Answers)
    ->  answers_dict(Text, "proved", true,
                     Answers, Dict)
    ;   Verdict = incomplete(Reason, Answers)
    ->  answers_dict(Text, "incomplete", false,
                     Answers, Dict0),
        term_text(Reason, S),
        Dict = Dict0.put(reason, S)
    ;   Verdict == not_proved
    ->  answers_dict(Text, "not_proved", true,
                     [], Dict)
    ;   Verdict = rejected(Why),
        term_text(Why, S),
        Dict = _{hypothesis:Text,
                 verdict:"rejected", reason:S}
    ).

answers_dict(Text, Kind, Complete, Answers, D) :-
    maplist(answer_dict, Answers, Dicts),
    length(Answers, N),
    D = _{hypothesis:Text, verdict:Kind,
          complete:Complete, answers_shown:N,
          answers:Dicts}.

answer_dict(Names-Facts, D) :-
    maplist(binding_pair, Names, Pairs),
    dict_pairs(BDict, _, Pairs),
    maplist(term_text, Facts, Strings),
    D = _{bindings:BDict, evidence:Strings}.

% binding_pair(+Binding, -Pair): the agent's
% variable name with its value as text, or null
% when the proof left the variable unbound.
binding_pair(Name = Term, Name-Value) :-
    (   var(Term)
    ->  Value = null
    ;   term_text(Term, Value)
    ).

% term_text(+Term, -String): Term as quoted Prolog
% text that reads back as Term; a variable inside
% it is written as a letter, or as _ if it occurs
% once.
term_text(Term, String) :-
    copy_term(Term, Copy),
    numbervars(Copy, 0, _, [singletons(true)]),
    term_string(Copy, String, [numbervars(true)]).
```

```{.prolog .query}
?- check_hypothesis("handle_leak(T)", _V),
   verdict_dict("handle_leak(T)", _V, _D),
   json_write_dict(current_output, _D,
                   [width(40), tab(80)]).
{
  "answers": [
    {
      "bindings": {"T":"event"},
      "evidence": [
        "handle_count(4120,event,12040)",
        "threshold(handle_type_count,5000)"
      ]
    }
  ],
  "answers_shown":1,
  "complete":true,
  "hypothesis":"handle_leak(T)",
  "verdict":"proved"
}
true.

?- _T = "no_component_symbols(M)",
   check_hypothesis(_T, [answers(2)], _V),
   verdict_dict(_T, _V, _D),
   json_write_dict(current_output, _D,
                   [width(40), tab(80)]).
{
  "answers": [
    {
      "bindings": {"M":"dbclient"},
      "evidence": [
        "module_info(dbclient,symbols,export)"
      ]
    },
    {
      "bindings": {"M":"cachelib"},
      "evidence": [
        "module_info(cachelib,symbols,none)"
      ]
    }
  ],
  "answers_shown":2,
  "complete":false,
  "hypothesis":"no_component_symbols(M)",
  "reason":"answer_limit(2)",
  "verdict":"incomplete"
}
true.
```

```{.prolog .query}
?- _T = "deadlock(critical_section, C)",
   check_hypothesis(_T, _V),
   verdict_dict(_T, _V, _D),
   get_dict(answers, _D, [_A]),
   get_dict(bindings, _A, B),
   with_output_to(string(_),
       json_write_dict(current_output, _D)).
B = _{'C':"[103,104]"}.

?- check_hypothesis("X = f(a)", _V),
   verdict_dict("X = f(a)", _V, _D),
   json_write_dict(current_output, _D,
                   [width(40)]).
{
  "hypothesis":"X = f(a)",
  "reason":"unsupported(X=f(a))",
  "verdict":"rejected"
}
true.

?- _T = "\\+ deadlock(mutant, C)",
   check_hypothesis(_T, _V),
   verdict_dict(_T, _V, _D),
   get_dict(answers, _D, [_A]),
   get_dict(bindings, _A, B).
B = _{'C':null}.
```

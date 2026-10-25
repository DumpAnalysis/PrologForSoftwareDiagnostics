# Chapter 17. The Pattern as a Predicate

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/17-pattern-as-predicate.md`.

## 17.1 Description and Recognizer

## 17.2 The Three Forms

```{.prolog .program}
:- [dump1].

% threshold(Name, Value): the named threshold used
% by the recognizers of this chapter.
threshold(spiking_share, 25).
threshold(handle_count, 10000).
threshold(frame_repeats, 5).
threshold(null_page, 0x1_0000).

% cpu_time(TID, Ms): the CPU time of TID in ms.
cpu_time(TID, Ms) :-
    thread_time(TID, User, Kernel),
    Ms is User + Kernel.

% total_cpu(Total): the CPU time of all threads.
total_cpu(Total) :-
    aggregate_all(sum(Ms), cpu_time(_, Ms),
                  Total).

% cpu_share(TID, Percent): the CPU time of TID as
% a percentage of the total.
cpu_share(TID, Percent) :-
    cpu_time(TID, Ms),
    total_cpu(Total),
    Percent is 100.0 * Ms / Total.

% spiking_thread(TID, E): TID is a Spiking Thread
% instance, and E is the evidence.
spiking_thread(TID, E) :-
    thread_time(TID, User, Kernel),
    cpu_share(TID, Share),
    threshold(spiking_share, Min),
    Share >= Min,
    E = evidence('Spiking Thread', TID,
        [ thread_time(TID, User, Kernel),
          cpu_share(TID, Share),
          threshold(spiking_share, Min)
        ]).

% spiking_thread(TID): TID is a Spiking Thread
% instance.
spiking_thread(TID) :-
    spiking_thread(TID, _).
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.

?- spiking_thread(102).
true.

?- spiking_thread(100).
false.

?- spiking_thread(T).
T = 102 ;
T = 107 ;
false.

?- spiking_thread(107, E).
E = evidence('Spiking Thread', 107, <...>).
```

## 17.3 Evidence

```{.prolog .query}
?- spiking_thread(102, evidence(P, I, _Facts)),
   forall(member(F, _Facts), ( print(F), nl )).
thread_time(102,8450,1230)
cpu_share(102,68.48249027237354)
threshold(spiking_share,25)
P = 'Spiking Thread',
I = 102.

?- spiking_thread(T, evidence(_, _, _Facts)),
   maplist(call, _Facts).
T = 102 ;
T = 107 ;
false.
```

```{.prolog .program}
% holds(Term): Term is a goal that succeeds, or an
% evidence or suspicion term all of whose goals
% hold.
holds(Term) :-
    (   Term = evidence(_, _, Goals)
    ->  maplist(holds, Goals)
    ;   Term = suspected(_, _, Goals)
    ->  maplist(holds, Goals)
    ;   once(Term)
    ).
```

```{.prolog .program}
% entails(Facts, Condition): Condition follows
% from the list Facts alone: a conjunction of
% goals, each a member of Facts or an arithmetic
% comparison between values the members bound.
entails(Facts, Condition) :-
    (   Condition = (A, B)
    ->  entails(Facts, A),
        entails(Facts, B)
    ;   comparison(Condition)
    ->  call(Condition)
    ;   member(Condition, Facts)
    ).

% comparison(Goal): Goal is an arithmetic
% comparison.
comparison(_ < _).
comparison(_ > _).
comparison(_ =< _).
comparison(_ >= _).
comparison(_ =:= _).
comparison(_ =\= _).
```

```{.prolog .query}
?- spiking_thread(102, evidence(_, T, _Fs)),
   entails(_Fs, ( cpu_share(T, S),
                  threshold(spiking_share, Min),
                  S >= Min )).
T = 102,
S = 68.48249027237354,
Min = 25 ;
false.

?- _Fs = [thread_time(100, 120, 40),
          threshold(spiking_share, 25)],
   maplist(call, _Fs).
true.

?- _Fs = [thread_time(100, 120, 40),
          threshold(spiking_share, 25)],
   entails(_Fs, ( cpu_share(102, S),
                  threshold(spiking_share, Min),
                  S >= Min )).
false.
```

## 17.4 Thresholds as Facts

```{.prolog .query}
?- threshold(Name, Value).
Name = spiking_share,
Value = 25 ;
Name = handle_count,
Value = 10000 ;
Name = frame_repeats,
Value = 5 ;
Name = null_page,
Value = 65536.
```

```{.prolog .program}
% handle_leak(Type, E): handles of Type exceed the
% threshold; a Handle Leak candidate.
handle_leak(Type, E) :-
    handle_count(PID, Type, Count),
    threshold(handle_count, Max),
    Count > Max,
    E = evidence('Handle Leak', Type,
        [ handle_count(PID, Type, Count),
          threshold(handle_count, Max)
        ]).

handle_leak(Type) :-
    handle_leak(Type, _).

% null_pointer_data(TID, E): TID faulted reading
% or writing an address in the null page.
null_pointer_data(TID, E) :-
    exception_record(TID, Code, Addr),
    Code =:= 0xc0000005,
    exception_info(TID, access, Access),
    Access \== execute,
    exception_info(TID, target, Target),
    threshold(null_page, Limit),
    Target < Limit,
    E = evidence('NULL Pointer (Data)', TID,
        [ exception_record(TID, Code, Addr),
          exception_info(TID, access, Access),
          exception_info(TID, target, Target),
          threshold(null_page, Limit)
        ]).

null_pointer_data(TID) :-
    null_pointer_data(TID, _).

% frame_function(Frame, F): F is the function of
% the frame/5 term Frame.
frame_function(frame(_, _, _, F, _), F).

% frame_runs(Frames, Runs): Runs is the list of
% maximal runs of consecutive frames of Frames
% that name one function, each run a list.
frame_runs([], []).
frame_runs([Frame | Frames],
           [[Frame | Run] | Runs]) :-
    frame_function(Frame, F),
    same_function(Frames, F, Run, Rest),
    frame_runs(Rest, Runs).

% same_function(Frames, F, Run, Rest): Run is the
% longest prefix of Frames whose frames name F;
% Rest is what follows it.
same_function(Frames, F, Run, Rest) :-
    (   Frames = [Frame | Frames1],
        frame_function(Frame, F)
    ->  Run = [Frame | Run1],
        same_function(Frames1, F, Run1, Rest)
    ;   Run = [],
        Rest = Frames
    ).

% frame_regularity(TID, E): the longest run of
% consecutive frames of TID naming one function is
% at least the threshold long; the frames of the
% run are the evidence.
frame_regularity(TID, E) :-
    thread(TID, _),
    findall(frame(TID, N, M, F, O),
            frame(TID, N, M, F, O), Frames0),
    sort(2, @=<, Frames0, Frames),
    frame_runs(Frames, Runs),
    aggregate_all(max(C, R),
                  ( member(R, Runs),
                    length(R, C)
                  ),
                  max(Count, Run)),
    threshold(frame_repeats, Min),
    Count >= Min,
    append(Run, [threshold(frame_repeats, Min)],
           Facts),
    E = evidence('Frame Regularity', TID, Facts).

frame_regularity(TID) :-
    frame_regularity(TID, _).
```

```{.prolog .query}
?- handle_leak(T, E).
T = event,
E = evidence('Handle Leak', event, <...>) ;
false.

?- null_pointer_data(T, evidence(_, _, _Facts)),
   forall(member(F, _Facts), ( print(F), nl )).
exception_record(109,3221225477,140718380167594)
exception_info(109,access,read)
exception_info(109,target,24)
threshold(null_page,65536)
T = 109.

?- frame_regularity(T).
T = 107 ;
false.

?- frame_regularity(107, evidence(_, _, _Facts)),
   length(_Facts, N), last(_Facts, Last).
N = 9,
Last = threshold(frame_repeats, 5).
```

```{.prolog .query}
?- findall(frame(0, N, m, F, 0),
           nth0(N, [f, f, g, f, f, g, f, f], F),
           _Fs),
   frame_runs(_Fs, _Runs),
   maplist(length, _Runs, Lengths).
Lengths = [2, 1, 2, 1, 2].
```

## 17.5 Composition

```{.prolog .program}
% blocked_on(TID, Addr, Owner): TID waits for the
% critical section at Addr, which Owner holds.
blocked_on(TID, Addr, Owner) :-
    waits_for(TID, critical_section, Addr),
    critical_section(Addr, Owner, _, _).

% blocked_thread(TID, E): TID is blocked on a
% critical section.
blocked_thread(TID, E) :-
    blocked_on(TID, Addr, Owner),
    critical_section(Addr, Owner, Lock, Rec),
    E = evidence('Blocked Thread (Software)', TID,
        [ waits_for(TID, critical_section, Addr),
          critical_section(Addr, Owner, Lock, Rec)
        ]).

blocked_thread(TID) :-
    blocked_thread(TID, _).

% deadlock(Pair, E): Pair is T1-T2, T1 < T2, each
% blocked on a section the other owns.
deadlock(T1-T2, E) :-
    blocked_on(T1, _, T2),
    blocked_on(T2, _, T1),
    T1 < T2,
    blocked_thread(T1, E1),
    blocked_thread(T2, E2),
    E = evidence('Deadlock (Critical Sections)',
                 T1-T2, [E1, E2]).

deadlock(Pair) :-
    deadlock(Pair, _).
```

```{.prolog .query}
?- deadlock(P).
P = 103-104 ;
false.

?- deadlock(103-104).
true.

?- deadlock(104-103).
false.

?- deadlock(P, _E), holds(_E).
P = 103-104 ;
false.

?- deadlock(_, evidence(_, _, [_E1, _E2])),
   _E1 = evidence(P1, I1, _),
   _E2 = evidence(P2, I2, _).
P1 = P2, P2 = 'Blocked Thread (Software)',
I1 = 103,
I2 = 104 ;
false.
```

```{.prolog .program}
% leaves(Term, Goals): Goals are the goals at the
% leaves of a nested evidence term, in order; a
% goal is its own leaf.
leaves(Term, Goals) :-
    (   Term = evidence(_, _, Facts)
    ->  maplist(leaves, Facts, Lists),
        append(Lists, Goals)
    ;   Goals = [Term]
    ).
```

```{.prolog .query}
?- deadlock(T1-T2, _E), leaves(_E, _Gs),
   length(_Gs, N),
   entails(_Gs,
           ( waits_for(T1, critical_section, A1),
             critical_section(A1, T2, _, _),
             waits_for(T2, critical_section, A2),
             critical_section(A2, T1, _, _) )).
T1 = 103,
T2 = 104,
N = 4,
A1 = 140695026508096,
A2 = 140695026507968 ;
false.
```

```{.prolog .program}
% wait_chain(Chain, E): Chain is a list of threads
% headed by a blocked thread, each waiting for a
% critical section the next owns, ending at a
% thread that is not blocked or that repeats.
wait_chain([TID | Rest], E) :-
    blocked_on(TID, _, _),
    chain_from(TID, [TID], Rest, Facts),
    E = evidence('Wait Chain (Critical Sections)',
                 [TID | Rest], Facts).

% chain_from(TID, Seen, Rest, Facts): Rest is the
% chain of owners from TID on, stopping at an
% unblocked thread or at one in Seen.
chain_from(TID, Seen, Rest, Facts) :-
    (   blocked_on(TID, A, Owner)
    ->  critical_section(A, Owner, L, R),
        Facts = [ waits_for(TID, critical_section,
                            A),
                  critical_section(A, Owner, L, R)
                | Facts1 ],
        (   memberchk(Owner, Seen)
        ->  Rest = [Owner],
            Facts1 = []
        ;   Rest = [Owner | Rest1],
            chain_from(Owner, [Owner | Seen],
                       Rest1, Facts1)
        )
    ;   Rest = [],
        Facts = []
    ).

wait_chain(Chain) :-
    wait_chain(Chain, _).
```

```{.prolog .query}
?- wait_chain(C).
C = [101, 103, 104, 103] ;
C = [103, 104, 103] ;
C = [104, 103, 104].

?- wait_chain([101, 103, 104, 103]).
true.

?- wait_chain([101 | Rest]).
Rest = [103, 104, 103].
```

## 17.6 The Catalog as Data

```{.prolog .program}
% pattern(Name, Kind, Chapter): the pattern Name
% occurs in artifacts of Kind; Chapter treats it.
pattern('Spiking Thread', memory_dump, 18).
pattern('Blocked Thread (Software)', memory_dump,
        18).
pattern('Frame Regularity', memory_dump, 18).
pattern('NULL Pointer (Data)', memory_dump, 19).
pattern('Wait Chain (Critical Sections)',
        memory_dump, 20).
pattern('Deadlock (Critical Sections)',
        memory_dump, 20).
pattern('Handle Leak', memory_dump, 21).
pattern('No Component Symbols', memory_dump, 22).
pattern('Hooked Functions (User Space)',
        memory_dump, 22).
pattern('Time Delta', software_trace, 25).
pattern('Discontinuity', software_trace, 25).

% recognizer(Name, Pred): Pred/2 is the explainer
% for the pattern Name.
recognizer('Spiking Thread', spiking_thread).
recognizer('Blocked Thread (Software)',
           blocked_thread).
recognizer('Frame Regularity', frame_regularity).
recognizer('NULL Pointer (Data)',
           null_pointer_data).
recognizer('Wait Chain (Critical Sections)',
           wait_chain).
recognizer('Deadlock (Critical Sections)',
           deadlock).
recognizer('Handle Leak', handle_leak).
recognizer('No Component Symbols',
           no_component_symbols).
recognizer('Hooked Functions (User Space)',
           hooked_functions).

% no_component_symbols(Module, E): Module has no
% symbol information.
no_component_symbols(M, E) :-
    module_info(M, symbols, none),
    E = evidence('No Component Symbols', M,
        [ module_info(M, symbols, none) ]).

no_component_symbols(M) :-
    no_component_symbols(M, _).

% hooked_functions(Function, E): the entry of
% Function in some module transfers control into
% another module.
hooked_functions(F, E) :-
    hooked(F, Module, Hooker),
    E = evidence('Hooked Functions (User Space)',
                 F, [hooked(F, Module, Hooker)]).

hooked_functions(F) :-
    hooked_functions(F, _).
```

```{.prolog .program}
% pattern_instances(Evidence): Evidence is the
% list of evidence terms of every pattern instance
% that a recognizer in the catalog finds.
pattern_instances(Evidence) :-
    findall(E,
            ( recognizer(_, Recognizer),
              call(Recognizer, _, E)
            ),
            Evidence).
```

```{.prolog .query}
?- pattern_instances(_Es), length(_Es, N).
N = 16.

?- pattern_instances(_Es),
   forall(member(evidence(P, I, _), _Es),
          format("~w: ~w~n", [P, I])).
Spiking Thread: 102
Spiking Thread: 107
Blocked Thread (Software): 101
Blocked Thread (Software): 103
Blocked Thread (Software): 104
Frame Regularity: 107
NULL Pointer (Data): 109
Wait Chain (Critical Sections): [101,103,104,103]
Wait Chain (Critical Sections): [103,104,103]
Wait Chain (Critical Sections): [104,103,104]
Deadlock (Critical Sections): 103-104
Handle Leak: event
No Component Symbols: cachelib
No Component Symbols: thirdparty_hook
Hooked Functions (User Space): CreateFileW
Hooked Functions (User Space): ReadFile
true.

?- pattern_instances(_Es), maplist(ground, _Es).
true.

?- pattern_instances(_Es), maplist(holds, _Es).
true.

?- pattern(P, _, _), \+ recognizer(P, _).
P = 'Time Delta' ;
P = 'Discontinuity'.

?- recognizer(P, _), \+ pattern(P, _, _).
false.
```

## 17.7 Reports and Severity

```{.prolog .program}
% severity(Pattern, Level): the level at which an
% instance of Pattern is reported.
severity('Deadlock (Critical Sections)',
         critical).
severity('NULL Pointer (Data)', critical).
severity('Spiking Thread', high).
severity('Handle Leak', high).
severity('Wait Chain (Critical Sections)',
         medium).
severity('Blocked Thread (Software)', medium).
severity('Frame Regularity', medium).
severity('Hooked Functions (User Space)', low).
severity('No Component Symbols', info).

% rank(Level, N): the levels in order of severity.
rank(critical, 1).
rank(high, 2).
rank(medium, 3).
rank(low, 4).
rank(info, 5).

% severity_rank(E, Rank): Rank is the rank of the
% pattern of the evidence term E.
severity_rank(evidence(Pattern, _, _), Rank) :-
    severity(Pattern, Level),
    rank(Level, Rank).

% report: print every recognized instance, grouped
% by severity, most severe first.
report :-
    pattern_instances(Evidence),
    map_list_to_pairs(severity_rank, Evidence,
                      Pairs),
    keysort(Pairs, Sorted),
    print_report(Sorted, 0).

% print_report(Pairs, Last): print the Rank-E
% pairs, with a heading whenever the rank changes
% from Last.
print_report([], _).
print_report([Rank-evidence(P, I, _) | Rest],
             Last) :-
    (   Rank == Last
    ->  true
    ;   rank(Level, Rank),
        format("~a~n", [Level])
    ),
    format("  ~a~t~33|~w~n", [P, I]),
    print_report(Rest, Rank).
```

```{.prolog .query}
?- report.
critical
  NULL Pointer (Data)            109
  Deadlock (Critical Sections)   103-104
high
  Spiking Thread                 102
  Spiking Thread                 107
  Handle Leak                    event
medium
  Blocked Thread (Software)      101
  Blocked Thread (Software)      103
  Blocked Thread (Software)      104
  Frame Regularity               107
  Wait Chain (Critical Sections) [101,103,104,103]
  Wait Chain (Critical Sections) [103,104,103]
  Wait Chain (Critical Sections) [104,103,104]
low
  Hooked Functions (User Space)  CreateFileW
  Hooked Functions (User Space)  ReadFile
info
  No Component Symbols           cachelib
  No Component Symbols           thirdparty_hook
true.
```

```{.prolog .program}
% by_severity(Order, E1, E2): compare two evidence
% terms by severity rank only.
by_severity(Order, E1, E2) :-
    severity_rank(E1, R1),
    severity_rank(E2, R2),
    compare(Order, R1, R2).
```

```{.prolog .query}
?- pattern_instances(_Es),
   predsort(by_severity, _Es, _Sorted),
   length(_Es, N), length(_Sorted, M).
N = 16,
M = 5.
```

## 17.8 Absence and the Closed World

```{.prolog .program}
% source(Relation, Command, Log): as in Chapter
% 15, for the relations this section asks about.
source(exception_record/3, '.exr -1',
       'dump1.log').
source(unloaded_module/2, lm, 'dump1.log').

% dump_info(Key, Value), ran(Command, Outcome),
% capture_policy(Relation, Needs): the capture
% record of Chapter 15 for the same relations.
% Dynamic, for the checks at the end of this
% section.
:- dynamic dump_info/2, ran/2, capture_policy/2.

dump_info(file, 'dump1.dmp').
dump_info(stream, unloaded_modules).
ran('.exr -1', ok).
ran(lm, ok).
capture_policy(exception_record/3, []).
capture_policy(unloaded_module/2,
               [stream(unloaded_modules)]).

% missing(Need): the recorded capture does not
% meet Need, a stream need; any other kind of
% need is an error.
missing(stream(S)) :-
    \+ dump_info(stream, S).
missing(Need) :-
    Need \= stream(_),
    domain_error(capture_need, Need).

% coverage(Relation, Status): complete when a
% policy is declared, a capture is recorded, the
% command ran and succeeded, and every need is
% met; incomplete(Missing) when needs are unmet or
% the command failed; unknown when the policy,
% the capture, or the command's run is not
% recorded.
coverage(Relation, Status) :-
    (   capture_policy(Relation, Needs),
        dump_info(_, _),
        source(Relation, Command, _),
        ran(Command, Outcome)
    ->  findall(Need,
                ( member(Need, Needs),
                  missing(Need) ),
                Unmet),
        (   Outcome == ok
        ->  Missing = Unmet
        ;   Missing = [ran(Command, Outcome)
                       | Unmet]
        ),
        (   Missing == []
        ->  Status = complete
        ;   Status = incomplete(Missing)
        )
    ;   Status = unknown
    ).

% absence(Relation, Status): Status is present
% when facts of Relation are loaded; absent when
% there are none, the command that produces them
% was run, and the coverage of Relation is
% complete; and unknown otherwise.
absence(F/A, Status) :-
    functor(Goal, F, A),
    (   current_predicate(F/A),
        call(Goal)
    ->  Status = present
    ;   source(F/A, _, _),
        coverage(F/A, complete)
    ->  Status = absent
    ;   Status = unknown
    ).
```

```{.prolog .query}
?- absence(exception_record/3, S).
S = present.

?- absence(unloaded_module/2, S).
S = absent.

?- absence(mutant/3, S).
S = unknown.
```

```{.prolog .query}
?- retract(dump_info(stream, unloaded_modules)),
   absence(unloaded_module/2, S),
   coverage(unloaded_module/2, C).
S = unknown,
C = incomplete([stream(unloaded_modules)]).

?- assertz(dump_info(stream, unloaded_modules)),
   absence(unloaded_module/2, S).
S = absent.

?- retract(ran(lm, ok)),
   absence(unloaded_module/2, S),
   coverage(unloaded_module/2, C).
S = C, C = unknown.

?- assertz(ran(lm, ok)),
   retract(capture_policy(unloaded_module/2, P)),
   absence(unloaded_module/2, S).
P = [stream(unloaded_modules)],
S = unknown.

?- assertz(capture_policy(unloaded_module/2,
       [stream(unloaded_modules)])),
   absence(unloaded_module/2, S).
S = absent.
```

## 17.9 Determinism

```{.prolog .query}
?- aggregate_all(count, spiking_thread(_), N).
N = 2.

?- aggregate_all(count, wait_chain(_), N).
N = 3.

?- aggregate_all(count, deadlock(_), N).
N = 1.

?- once(frame_regularity(T)).
T = 107.
```

## 17.10 Testing Recognizers

```{.prolog .program}
:- use_module(library(plunit)).

:- begin_tests(dump1_patterns).

test(spiking, all(T == [102, 107])) :-
    spiking_thread(T).

test(not_spiking, fail) :-
    spiking_thread(100).

test(deadlock, [nondet, true(P == 103-104)]) :-
    deadlock(P).

test(null_pointer, T == 109) :-
    null_pointer_data(T).

test(chains, all(C == [[101, 103, 104, 103],
                       [103, 104, 103],
                       [104, 103, 104]])) :-
    wait_chain(C).

test(instance_count, N == 16) :-
    pattern_instances(Es),
    length(Es, N).

test(evidence_ground) :-
    pattern_instances(Es),
    maplist(ground, Es).

test(evidence_holds) :-
    pattern_instances(Es),
    maplist(holds, Es).

test(deadlock_entailed, [nondet]) :-
    deadlock(T1-T2, E),
    leaves(E, Gs),
    entails(Gs,
            ( waits_for(T1, critical_section, A1),
              critical_section(A1, T2, _, _),
              waits_for(T2, critical_section, A2),
              critical_section(A2, T1, _, _) )).

:- end_tests(dump1_patterns).
```

```{.prolog .query}
?- set_prolog_flag(verbose, normal).
true.

?- run_tests.
% PL-Unit: dump1_patterns ......... passed <...>
% All 9 tests passed
true.
```

```{.prolog .program}
:- begin_tests(wrong_claims).

test(main_thread_spikes) :-
    spiking_thread(100).

test(share, true(S =:= 50)) :-
    cpu_share(102, S).

:- end_tests(wrong_claims).
```

```{.prolog .query}
?- run_tests(wrong_claims).
% PL-Unit: wrong_claims
ERROR: <...>
<...>test main_thread_spikes: failed
ERROR: <...>
<...>test share: wrong answer (compared using =:=)
ERROR:     Expected: 50
ERROR:     Got:      68.48249027237354
<...>
% 2 tests failed
% 0 tests passed
false.
```

## 17.11 Conventions for Parts III and IV

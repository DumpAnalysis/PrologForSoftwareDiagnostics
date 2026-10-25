# Chapter 23. Dump Quality, Composition, and Reports

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/23-dump-quality-and-reports.md`.

```{.prolog .program}
:- [dump1].
:- use_module(patterns_dump).

% pattern(Name, Artifact, Chapter): the catalog
% entries treated in this chapter.
pattern('Manual Dump (Process)', memory_dump, 23).
pattern('Truncated Dump', memory_dump, 23).
pattern('Inconsistent Dump', memory_dump, 23).
pattern('Early Crash Dump', memory_dump, 23).
pattern('False Positive Dump', memory_dump, 23).
pattern('Corrupt Dump', memory_dump, 23).
pattern('No Current Thread', memory_dump, 23).
pattern('Step Dumps', memory_dump, 23).

% dump_info(Key, Value): what the debugger reports
% about the dump file itself. An extension of the
% schema.
dump_info(kind, process).
dump_info(truncated, false).
dump_info(current_thread, 109).
dump_info(process_uptime_s, 1860).

% threshold(Name, Value): the module's thresholds
% are those of Chapters 18 to 21; this chapter
% adds its one limit to the multifile predicate.
patterns_dump:threshold(early_uptime_s, 10).
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.

?- dump_info(kind, K), dump_info(truncated, T).
K = process,
T = false.

?- predicate_property(spiking_thread(_),
                      imported_from(M)).
M = patterns_dump.

?- aggregate_all(count, threshold(_, _), N),
   threshold(early_uptime_s, S).
N = 12,
S = 10.

?- threshold(spiking_share, Min),
   threshold(frame_run, Run),
   threshold(overflow_run, Overflow).
Min = 25,
Run = 4,
Overflow = 6.
```

## 23.1 Manual Dump (Process)

```{.prolog .program}
% break_in_frame(TID): a frame left by a debugger
% break-in on the stack trace of TID.
break_in_frame(TID) :-
    frame(TID, _, _, Function, _),
    memberchk(Function, [ 'DbgBreakPoint',
                          'DbgUiRemoteBreakin' ]).

% manual_dump(Sign): the dump was written on
% request: no thread has an exception record, or a
% debugger broke in.
manual_dump(no_exception_record) :-
    \+ exception_record(_, _, _).
manual_dump(break_in(TID)) :-
    break_in_frame(TID).
```

```{.prolog .query}
?- main_thread(T).
T = 100 ;
false.

?- main_thread(T), \+ exception_record(T, _, _).
T = 100 ;
false.

?- manual_dump(Sign).
false.

?- exception_record(T, Code, _),
   format("~16r~n", [Code]).
c0000005
T = 109,
Code = 3221225477.
```

## 23.2 Truncated Dump

```{.prolog .program}
% bottom_frame(TID, Function): the function of the
% deepest frame of TID.
bottom_frame(TID, Function) :-
    thread(TID, _),
    aggregate_all(max(N, F),
                  frame(TID, N, _, F, _),
                  max(_, Function)).

% truncation_sign(Sign): one symptom of a dump
% that holds less than the process had.
truncation_sign(flagged) :-
    dump_info(truncated, true).
truncation_sign(module_missing(Module)) :-
    distinct(Module, frame(_, _, Module, _, _)),
    \+ module(Module, _, _).
truncation_sign(no_frames(TID)) :-
    thread(TID, _),
    \+ frame(TID, _, _, _, _).
truncation_sign(incomplete_stack(TID)) :-
    bottom_frame(TID, Function),
    Function \== 'RtlUserThreadStart'.

% truncated_dump(Signs): the dump shows at least
% one sign of truncation.
truncated_dump(Signs) :-
    findall(Sign, truncation_sign(Sign), Signs),
    Signs \== [].
```

```{.prolog .query}
?- truncated_dump(Signs).
false.

?- forall(thread(T, _),
          bottom_frame(T, 'RtlUserThreadStart')).
true.

?- forall(frame(_, _, M, _, _), module(M, _, _)).
true.
```

## 23.3 Inconsistent Dump

```{.prolog .program}
% inconsistency(Finding): one disagreement between
% two kinds of fact in the dump.
inconsistency(owner_not_a_thread(Addr, Owner)) :-
    critical_section(Addr, Owner, _, _),
    Owner =\= 0,
    \+ thread(Owner, _).
inconsistency(wait_on_unknown_section(TID)) :-
    waits_for(TID, critical_section, Addr),
    \+ critical_section(Addr, _, _, _).
inconsistency(wait_on_free_section(TID)) :-
    waits_for(TID, critical_section, Addr),
    critical_section(Addr, 0, _, _).
inconsistency(state_without_record(TID)) :-
    thread_state(TID, waiting(exception)),
    \+ exception_record(TID, _, _).
inconsistency(record_without_state(TID)) :-
    exception_record(TID, _, _),
    \+ thread_state(TID, waiting(exception)).
inconsistency(fault_outside_top_module(TID)) :-
    exception_record(TID, _, Addr),
    frame(TID, 0, Module, _, _),
    \+ ( module(Module, Base, Size),
         Base =< Addr,
         Addr < Base + Size
       ).

% inconsistent_dump(Findings): the dump disagrees
% with itself in at least one way.
inconsistent_dump(Findings) :-
    findall(F, inconsistency(F), Findings),
    Findings \== [].
```

```{.prolog .query}
?- inconsistent_dump(F).
false.

?- exception_record(109, _, A),
   frame(109, 0, M, _, _),
   module(M, Base, Size),
   Base =< A, A < Base + Size.
A = 140718380167594,
M = dbclient,
Base = 140718380154880,
Size = 450560.

?- critical_section(Addr, Owner, _, _),
   Owner =\= 0, thread(Owner, _),
   format("~16r~n", [Addr]).
7ff61d13a0c0
Addr = 140695026507968,
Owner = 103 ;
7ff61d13a140
Addr = 140695026508096,
Owner = 104 ;
false.
```

## 23.4 Early Crash Dump

```{.prolog .program}
% early_sign(Sign): a symptom that the process had
% barely started when the dump was written.
early_sign(short_uptime(Seconds)) :-
    dump_info(process_uptime_s, Seconds),
    threshold(early_uptime_s, Max),
    Seconds < Max.
early_sign(single_thread) :-
    aggregate_all(count, thread(_, _), 1).
early_sign(thread_in_loader(TID)) :-
    bottom_frame(TID, 'LdrInitializeThunk').

% early_crash_dump(Signs): the dump shows at least
% one sign of an early crash.
early_crash_dump(Signs) :-
    findall(Sign, early_sign(Sign), Signs),
    Signs \== [].
```

```{.prolog .query}
?- early_crash_dump(S).
false.

?- dump_info(process_uptime_s, S), M is S // 60.
S = 1860,
M = 31.

?- main_thread(T), frame(T, 2, appserver, F, _).
T = 100,
F = 'MainLoop' ;
false.
```

## 23.5 False Positive Dump

```{.prolog .program}
% benign_code(Code, Kind): exception codes that a
% process raises and survives when a debugger is
% attached.
benign_code(0x80000003, breakpoint).
benign_code(0x80000004, single_step).
benign_code(0x406d1388, thread_naming).
benign_code(0x40010006, debug_print).

% false_positive_dump(TID, Kind): the exception
% record of TID is of a benign kind and no other
% thread has a record that is not.
false_positive_dump(TID, Kind) :-
    exception_record(TID, Code, _),
    benign_code(Code, Kind),
    \+ ( exception_record(Other, OtherCode, _),
         Other \== TID,
         \+ benign_code(OtherCode, _)
       ).
```

```{.prolog .query}
?- false_positive_dump(T, K).
false.

?- exception_record(_, Code, _),
   Severity is Code >> 30.
Code = 3221225477,
Severity = 3.

?- benign_code(Code, _), Severity is Code >> 30,
   format("~16r ~d~n", [Code, Severity]), fail.
80000003 2
80000004 2
406d1388 1
40010006 1
false.
```

## 23.6 Corrupt Dump

```{.prolog .program}
% census(Counts): the number of facts of each
% predicate of the schema.
census(Counts) :-
    findall(Name/Arity-N,
            ( schema_predicate(Name/Arity),
              functor(Goal, Name, Arity),
              aggregate_all(count, Goal, N)
            ),
            Counts).

schema_predicate(process/2).
schema_predicate(module/3).
schema_predicate(module_info/3).
schema_predicate(thread/2).
schema_predicate(thread_time/3).
schema_predicate(thread_state/2).
schema_predicate(frame/5).
schema_predicate(exception_record/3).
schema_predicate(exception_info/3).
schema_predicate(critical_section/4).
schema_predicate(waits_for/3).
schema_predicate(handle_count/3).
schema_predicate(heap/4).
schema_predicate(last_error/2).
schema_predicate(hooked/3).

% print_census: one line per schema predicate.
print_census :-
    census(Counts),
    forall(member(Pred-N, Counts),
           format("~w~t~20|~t~d~4+~n",
                  [Pred, N])).
```

```{.prolog .query}
?- print_census.
process/2              1
module/3              10
module_info/3         20
thread/2              10
thread_time/3         10
thread_state/2        10
frame/5               78
exception_record/3     1
exception_info/3       2
critical_section/4     3
waits_for/3            3
handle_count/3         6
heap/4                 3
last_error/2           6
hooked/3               2
true.

?- census(_C), member(P-0, _C).
false.
```

## 23.7 No Current Thread

```{.prolog .program}
% no_current_thread: the debugger reported no
% current thread when it opened the dump.
no_current_thread :-
    dump_info(current_thread, none).
```

```{.prolog .query}
?- no_current_thread.
false.

?- dump_info(current_thread, T),
   exception_record(T, _, _).
T = 109.
```

## 23.8 Deadlock (Critical Sections), Blocked Thread (Software), and Wait Chain (Critical Sections)

```{.prolog .query}
?- deadlock(critical_section, C).
C = [103, 104] ;
false.

?- wait_chain(critical_section, Chain).
Chain = [101, 103, 104] ;
Chain = [103, 104] ;
Chain = [104, 103] ;
false.

?- deadlock(critical_section, C),
   forall(member(T, C), blocked_thread(T)).
C = [103, 104] ;
false.

?- deadlock(critical_section, C), member(T, C),
   wait_chain(critical_section, [T | Rest]),
   last([T | Rest], Last),
   wait_edge(critical_section, Last, _Back),
   memberchk(_Back, [T | Rest]).
C = [103, 104],
T = 103,
Rest = [104],
Last = 104 ;
C = [103, 104],
T = 104,
Rest = [103],
Last = 103 ;
false.
```

```{.prolog .query}
?- deadlock(critical_section, C,
            evidence(Name, _, _Fs)),
   ground(_Fs), maplist(call, _Fs),
   length(_Fs, N).
C = [103, 104],
Name = 'Deadlock (Critical Sections)',
N = 4 ;
false.
```

```{.prolog .program}
% implies(Pattern, Pattern2): every instance of
% Pattern contains instances of Pattern2.
implies('Deadlock (Critical Sections)',
        'Blocked Thread (Software)').
implies('Blocked Thread (Software)',
        'Wait Chain (Critical Sections)').
```

## 23.9 Step Dumps

```{.prolog .program}
% heap_at(Dump, Heap, ReservedKb, CommittedKb,
% FreeKb) and dump_time(Dump, Seconds): the series
% of Chapter 21. An extension of the schema.
heap_at(dump1a, 0x0000_0210_a000_0000,
        2097152, 1703936, 40960).
heap_at(dump1a, 0x0000_0210_a001_0000,
        1024, 256, 128).
heap_at(dump1a, 0x0000_0210_a200_0000,
        65536, 59392, 2048).
heap_at(dump1b, 0x0000_0210_a000_0000,
        2097152, 1769472, 32768).
heap_at(dump1b, 0x0000_0210_a001_0000,
        1024, 256, 128).
heap_at(dump1b, 0x0000_0210_a200_0000,
        65536, 32768, 4096).
heap_at(dump1, Heap, R, C, F) :-
    heap(Heap, R, C, F).

dump_time(dump1a, 0).
dump_time(dump1b, 600).
dump_time(dump1, 1200).

% step_dumps(Heap, Steps): Steps lists, for each
% dump after the first, Time-Delta where Delta is
% the change of committed KB of Heap since the
% previous dump.
step_dumps(Heap, Steps) :-
    heap(Heap, _, _, _),
    findall(T-C,
            ( heap_at(D, Heap, _, C, _),
              dump_time(D, T)
            ),
            Pairs),
    keysort(Pairs, [_-C0 | Series]),
    steps_from(Series, C0, Steps).

steps_from([], _, []).
steps_from([T-C | Series], Prev, [T-D | Steps]) :-
    D is C - Prev,
    steps_from(Series, C, Steps).

% dump_sequence(Dumps): the dumps in time order.
dump_sequence(Dumps) :-
    findall(T-D, dump_time(D, T), Pairs),
    keysort(Pairs, Sorted),
    pairs_values(Sorted, Dumps).
```

```{.prolog .query}
?- dump_sequence(Ds).
Ds = [dump1a, dump1b, dump1].

?- forall(step_dumps(H, Steps),
          format("~16r ~w~n", [H, Steps])).
210a0000000 [600-65536,1200-65536]
210a0010000 [600-0,1200-0]
210a2000000 [600- -26624,1200-28672]
true.

?- memory_leak(H), format("~16r~n", [H]).
210a0000000
H = 2270427086848 ;
false.

?- step_dumps(H, Steps),
   forall(member(_-D, Steps), D > 0),
   memory_leak(H).
H = 2270427086848,
Steps = [600-65536, 1200-65536] ;
false.
```

## 23.10 The Analysis Report

```{.prolog .query}
?- spiking_thread(T).
T = 102 ;
T = 107 ;
false.

?- frame_regularity(T, Key, N).
T = 107,
Key = reportengine-'Node::Visit',
N = 8 ;
false.

?- null_pointer_data(T), not_my_version(M).
T = 109,
M = dbclient ;
false.

?- stack_overflow(T, _Finding),
   functor(_Finding, Form, 3).
T = 107,
Form = suspected ;
false.
```

```{.prolog .program}
% instance(Pattern, Instance): a recognized
% instance of Pattern in the dump.
instance('Manual Dump (Process)', Sign) :-
    manual_dump(Sign).
instance('Truncated Dump', signs(Signs)) :-
    truncated_dump(Signs).
instance('Inconsistent Dump', findings(Fs)) :-
    inconsistent_dump(Fs).
instance('Early Crash Dump', signs(Signs)) :-
    early_crash_dump(Signs).
instance('False Positive Dump',
         thread(TID, Kind)) :-
    false_positive_dump(TID, Kind).
instance('Deadlock (Critical Sections)',
         threads(Cycle)) :-
    deadlock(critical_section, Cycle).
instance('NULL Pointer (Data)', thread(TID)) :-
    null_pointer_data(TID).
instance('Stack Overflow (User Mode)',
         thread(TID)) :-
    stack_overflow(TID, evidence(_, TID, _)).
instance('Exception Stack Trace', thread(TID)) :-
    exception_stack_trace(TID, _).
instance('Insufficient Memory (Committed Memory)',
         Inst) :-
    insufficient_memory(committed_memory, Inst).
instance('Insufficient Memory (Handle Leak)',
         Inst) :-
    insufficient_memory(handle_leak, Inst).
instance('Memory Leak (Process Heap)', heap(H)) :-
    memory_leak(H).
instance('Handle Leak', handles(Type)) :-
    handle_leak(Type).
instance('Spiking Thread', thread(TID)) :-
    spiking_thread(TID).
instance('Frame Regularity',
         frames(TID, Key, N)) :-
    frame_regularity(TID, Key, N).
instance('Blocked Thread (Software)',
         thread(TID)) :-
    blocked_thread(TID).
instance('Wait Chain (Critical Sections)',
         chain(Chain)) :-
    wait_chain(critical_section, Chain).
instance('Not My Version', module(M)) :-
    not_my_version(M).
instance('Hooked Functions (User Space)',
         hook(F, M, H)) :-
    hooked_functions(M, H, Fs),
    member(F, Fs).
instance('Unknown Component', module(M)) :-
    unknown_component(M).
instance('No Component Symbols', module(M)) :-
    no_component_symbols(M).
instance('Suspended Thread', thread(TID)) :-
    suspended_thread(TID).
instance('Last Error Collection',
         error(TID, C)) :-
    last_error_collection(Pairs),
    member(TID-C, Pairs),
    C =\= 0.
instance('Main Thread', thread(TID)) :-
    main_thread(TID).
instance('Step Dumps', dumps(Dumps)) :-
    dump_sequence(Dumps),
    Dumps = [_, _ | _].

% suspicion(Pattern, Instance): an instance of
% Pattern that a recognizer reports with a
% suspicion term rather than an evidence term.
suspicion('Stack Overflow (User Mode)',
          thread(TID)) :-
    stack_overflow(TID, suspected(_, TID, _)).

% severity(Pattern, Rank): the order of the
% report; 0 qualifies the dump, 1 is most severe.
severity('Manual Dump (Process)', 0).
severity('Truncated Dump', 0).
severity('Inconsistent Dump', 0).
severity('Early Crash Dump', 0).
severity('False Positive Dump', 0).
severity('Deadlock (Critical Sections)', 1).
severity('NULL Pointer (Data)', 1).
severity('Stack Overflow (User Mode)', 1).
severity('Exception Stack Trace', 2).
severity('Insufficient Memory (Committed Memory)',
         2).
severity('Insufficient Memory (Handle Leak)', 2).
severity('Memory Leak (Process Heap)', 2).
severity('Handle Leak', 2).
severity('Spiking Thread', 2).
severity('Frame Regularity', 3).
severity('Blocked Thread (Software)', 3).
severity('Wait Chain (Critical Sections)', 3).
severity('Not My Version', 3).
severity('Hooked Functions (User Space)', 3).
severity('Unknown Component', 3).
severity('No Component Symbols', 4).
severity('Suspended Thread', 4).
severity('Last Error Collection', 4).
severity('Main Thread', 4).
severity('Step Dumps', 4).

% rank_name(Rank, Name): the report's word for a
% severity rank.
rank_name(0, 'dump quality').
rank_name(1, critical).
rank_name(2, major).
rank_name(3, minor).
rank_name(4, informational).
```

```{.prolog .query}
?- aggregate_all(count, severity(_, _), N),
   aggregate_all(count,
                 distinct(P, instance(P, _)), R),
   aggregate_all(count,
                 distinct(P, suspicion(P, _)), S).
N = 25,
R = 19,
S = 1.

?- severity(P, 1), instance(P, I).
P = 'Deadlock (Critical Sections)',
I = threads([103, 104]) ;
P = 'NULL Pointer (Data)',
I = thread(109) ;
false.

?- severity(P, 1), suspicion(P, I).
P = 'Stack Overflow (User Mode)',
I = thread(107) ;
false.
```

```{.prolog .program}
% describe(Instance, Format, Args): how to print
% an instance of each kind.
describe(thread(T), "thread ~d", [T]).
describe(thread(T, Kind), "thread ~d (~a)",
         [T, Kind]).
describe(threads(Ts), "threads ~w", [Ts]).
describe(chain(Chain), "wait chain ~w", [Chain]).
describe(module(M), "module ~a", [M]).
describe(heap(H), "heap 0x~16r", [H]).
describe(process, "the process", []).
describe(process(PID), "process ~d", [PID]).
describe(handles(Type), "~a handles", [Type]).
describe(hook(F, M, H), "~a!~a <- ~a", [M, F, H]).
describe(frames(T, _-F, N),
         "thread ~d: ~d frames of ~a", [T, N, F]).
describe(error(T, C),
         "thread ~d: last error 0x~16r", [T, C]).
describe(dumps(Ds), "dumps ~w", [Ds]).

% print_instance(Instance): one indented line.
print_instance(Instance) :-
    (   describe(Instance, Format, Args)
    ->  format("    "),
        format(Format, Args),
        nl
    ;   format("    ~w~n", [Instance])
    ).

% recognized(Rank, Pattern): Pattern has at least
% one instance.
recognized(Rank, Pattern) :-
    severity(Pattern, Rank),
    once(instance(Pattern, _)).

% report_pattern(Rank, Pattern): the heading, the
% instances, and the entailments of Pattern.
report_pattern(Rank, Pattern) :-
    rank_name(Rank, Word),
    format("[~a] ~a~n", [Word, Pattern]),
    forall(instance(Pattern, Instance),
           print_instance(Instance)),
    forall(implies(Other, Pattern),
           format("    (entailed by ~a)~n",
                  [Other])).
```

```{.prolog .query}
?- report_pattern(1,
                  'Deadlock (Critical Sections)').
[critical] Deadlock (Critical Sections)
    threads [103,104]
true.

?- report_pattern(3, 'Blocked Thread (Software)').
[minor] Blocked Thread (Software)
    thread 101
    thread 103
    thread 104
    (entailed by Deadlock (Critical Sections))
true.
```

```{.prolog .program}
% not_examined(What): data the report would need
% and the knowledge base does not hold.
not_examined('heap verification results').
not_examined('heap operation logs').
not_examined('raw stack words').
not_examined('function parameters').
not_examined('the environment block').
not_examined('executable regions not in modules').

% limit_lines(Lines): what the report does not
% claim.
limit_lines([
    "- that any recognized pattern is the cause",
    "  of the failure; a pattern is a state the",
    "  dump shows, and causes are inferred;",
    "- that a pattern not recognized is absent;",
    "  the recognizers see the facts the schema",
    "  holds, and the dump holds more;",
    "- that the thresholds are right for this",
    "  process; they encode an analyst's limits;",
    "- that the stack traces are correct; they",
    "  are the debugger's reconstructions;",
    "- anything about time before or after the",
    "  moment the dump was written, except what",
    "  the step dumps show at their moments."
]).

report_header :-
    process(PID, Name),
    format("Analysis report: ~a (PID ~d)~n",
           [Name, PID]),
    aggregate_all(count, thread(_, _), Threads),
    aggregate_all(count, module(_, _, _),
                  Modules),
    dump_info(kind, Kind),
    format("~a memory dump, ", [Kind]),
    format("~d threads, ~d modules~n",
           [Threads, Modules]),
    nl.

report_recognized :-
    format("Recognized, most severe first:~n"),
    findall(Rank-Pattern,
            recognized(Rank, Pattern),
            Pairs),
    keysort(Pairs, Sorted),
    forall(member(Rank-Pattern, Sorted),
           report_pattern(Rank, Pattern)),
    nl.

report_suspected :-
    format("Suspected, for the analyst:~n"),
    forall(suspicion(Pattern, Instance),
           ( format("[suspected] ~a~n",
                    [Pattern]),
             print_instance(Instance)
           )),
    nl.

report_absent :-
    format("Looked for and not recognized:~n"),
    forall(( severity(Pattern, _),
             \+ instance(Pattern, _)
           ),
           format("    ~a~n", [Pattern])),
    nl.

report_not_examined :-
    format("Not examined, for want of facts:~n"),
    forall(not_examined(What),
           format("    ~a~n", [What])),
    nl.

report_limits :-
    format("This report does not claim~n"),
    limit_lines(Lines),
    forall(member(Line, Lines),
           format("~s~n", [Line])).

% report: the analysis report of the dump.
report :-
    report_header,
    report_recognized,
    report_suspected,
    report_absent,
    report_not_examined,
    report_limits.
```

```{.prolog .query}
?- report.
Analysis report: AppServer.exe (PID 4120)
process memory dump, 10 threads, 10 modules

Recognized, most severe first:
[critical] Deadlock (Critical Sections)
    threads [103,104]
[critical] NULL Pointer (Data)
    thread 109
[major] Exception Stack Trace
    thread 109
[major] Insufficient Memory (Committed Memory)
    heap 0x210a0000000
    the process
[major] Insufficient Memory (Handle Leak)
    process 4120
[major] Memory Leak (Process Heap)
    heap 0x210a0000000
[major] Handle Leak
    event handles
[major] Spiking Thread
    thread 102
    thread 107
[minor] Frame Regularity
    thread 107: 8 frames of Node::Visit
[minor] Blocked Thread (Software)
    thread 101
    thread 103
    thread 104
    (entailed by Deadlock (Critical Sections))
[minor] Wait Chain (Critical Sections)
    wait chain [101,103,104]
    wait chain [103,104]
    wait chain [104,103]
    (entailed by Blocked Thread (Software))
[minor] Not My Version
    module dbclient
[minor] Hooked Functions (User Space)
    kernelbase!CreateFileW <- thirdparty_hook
    kernelbase!ReadFile <- thirdparty_hook
[minor] Unknown Component
    module thirdparty_hook
[informational] No Component Symbols
    module dbclient
    module cachelib
    module thirdparty_hook
[informational] Suspended Thread
    thread 108
[informational] Last Error Collection
    thread 109: last error 0x3e6
[informational] Main Thread
    thread 100
[informational] Step Dumps
    dumps [dump1a,dump1b,dump1]

Suspected, for the analyst:
[suspected] Stack Overflow (User Mode)
    thread 107

Looked for and not recognized:
    Manual Dump (Process)
    Truncated Dump
    Inconsistent Dump
    Early Crash Dump
    False Positive Dump
    Stack Overflow (User Mode)

Not examined, for want of facts:
    heap verification results
    heap operation logs
    raw stack words
    function parameters
    the environment block
    executable regions not in modules

This report does not claim
- that any recognized pattern is the cause
  of the failure; a pattern is a state the
  dump shows, and causes are inferred;
- that a pattern not recognized is absent;
  the recognizers see the facts the schema
  holds, and the dump holds more;
- that the thresholds are right for this
  process; they encode an analyst's limits;
- that the stack traces are correct; they
  are the debugger's reconstructions;
- anything about time before or after the
  moment the dump was written, except what
  the step dumps show at their moments.
true.
```

### 23.10.1 Two Boundary Cases

```{.prolog .program .fresh file=boundary.pl}
% boundary.pl -- dump1.pl extended with seven
% synthetic threads for the boundary checks of
% Section 23.10. An extension of the schema; every
% value is invented. frame/5 is dynamic, so that
% the directive at the end can add frames.
:- discontiguous thread/2, frame/5,
   exception_record/3, exception_info/3.
:- dynamic frame/5.
:- include(dump1).
:- use_module(patterns_dump).

% 130: an access violation executing at address 0
thread(130, 4120).
exception_record(130, 0xc0000005, 0x0).
exception_info(130, access, execute).
exception_info(130, target, 0x0).

% 131: one function in three separate runs of two
thread(131, 4120).
frame(131, 0, appserver, f, 0x10).
frame(131, 1, appserver, f, 0x10).
frame(131, 2, appserver, g, 0x20).
frame(131, 3, appserver, f, 0x10).
frame(131, 4, appserver, f, 0x10).
frame(131, 5, appserver, g, 0x20).
frame(131, 6, appserver, f, 0x10).
frame(131, 7, appserver, f, 0x10).

% 132-134: twelve frames with a longest run of
% four, five, and six; 135: eight frames with a
% run of six; 136: three frames and the stack
% overflow status code. The frames are built by
% the directive below, one per function listed.
thread(132, 4120).
thread(133, 4120).
thread(134, 4120).
thread(135, 4120).
thread(136, 4120).
exception_record(136, 0xc00000fd,
                 0x7ff6_1d11_0010).

:- forall(member(TID-Functions,
                 [ 132-[f,f,f,f,g,h,i,j,k,l,m,n],
                   133-[f,f,f,f,f,g,h,i,j,k,l,m],
                   134-[f,f,f,f,f,f,g,h,i,j,k,l],
                   135-[f,f,f,f,f,f,g,h],
                   136-[a,b,c] ]),
          forall(nth0(N, Functions, F),
                 assertz(frame(TID, N, appserver,
                               F, 0x10)))).
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.

?- exception_record(130, Code, _),
   exception_info(130, access, Access),
   exception_info(130, target, Target),
   threshold(null_page, Limit).
Code = 3221225477,
Access = execute,
Target = 0,
Limit = 65536 ;
false.

?- null_pointer_data(130).
false.

?- null_pointer_data(T).
T = 109 ;
false.
```

```{.prolog .query}
?- aggregate_all(count, frame(131, _, _, f, _),
                 N).
N = 6.

?- stack_trace_signature(131, _S), runs(_S, _Rs),
   pairs_values(_Rs, Lengths).
Lengths = [2, 1, 2, 1, 2].

?- frame_regularity(131, Key, N).
false.

?- retract(threshold(frame_run, 4)),
   assertz(threshold(frame_run, 2)),
   aggregate_all(max(N),
                 frame_regularity(131, _, N),
                 Max).
Max = 2.

?- frame_regularity(131, Key, N).
Key = appserver-f,
N = 2 ;
Key = appserver-f,
N = 2 ;
Key = appserver-f,
N = 2.
```

### 23.10.2 The Two Run Thresholds

```{.prolog .program}
% run_report(TID): the depth of TID, the runs that
% reach frame_run, and the forms of its findings.
run_report(TID) :-
    stack_depth(TID, Depth),
    findall(C, frame_regularity(TID, _, C), Runs),
    findall(Form,
            ( stack_overflow(TID, F),
              functor(F, Form, 3)
            ),
            Forms),
    format("~d depth ~d runs ~w ~w~n",
           [TID, Depth, Runs, Forms]).
```

```{.prolog .query}
?- retract(threshold(frame_run, 2)),
   assertz(threshold(frame_run, 4)),
   threshold(frame_run, R),
   threshold(overflow_run, O).
R = 4,
O = 6.

?- forall(member(T, [107, 132, 133, 134, 135,
                    136]),
          run_report(T)).
107 depth 14 runs [8] [suspected]
132 depth 12 runs [4] []
133 depth 12 runs [5] []
134 depth 12 runs [6] [suspected]
135 depth 8 runs [6] []
136 depth 3 runs [] [evidence]
true.

?- stack_overflow(T, suspected(_, _, _Gs)),
   memberchk(threshold(overflow_run, Min), _Gs).
T = 107,
Min = 6 ;
T = 134,
Min = 6 ;
false.
```

### 23.10.3 The Evidence Contract from an Importing Module

```{.prolog .query}
?- explainer(Goal, _), functor(Goal, Name, Arity),
   format("~a/~d~n", [Name, Arity]), fail.
spiking_thread/2
blocked_thread/2
null_pointer_data/2
stack_overflow/2
deadlock/3
insufficient_memory/3
false.

?- check_explainers.
spiking_thread/2: 2 of 2 ok
blocked_thread/2: 3 of 3 ok
null_pointer_data/2: 1 of 1 ok
stack_overflow/2: 3 of 3 ok
deadlock/3: 1 of 1 ok
insufficient_memory/3: 1 of 1 ok
true.

?- spiking_thread(102, evidence(_, _, _Fs)),
   maplist(call, _Fs),
   predicate_property(cpu_time(_, _),
                      imported_from(M)).
M = patterns_dump.
```

```{.prolog .query}
?- insufficient_memory(committed_memory, heap(H),
                       evidence(_, _, _Fs)),
   forall(member(F, _Fs), ( print(F), nl )).
heap(2270427086848,2097152,1835008,24576)
threshold(committed_ratio,0.85)
threshold(large_heap_kb,1048576)
H = 2270427086848 ;
false.

?- null_pointer_data(109, evidence(_, _, _Fs)),
   forall(member(F, _Fs), ( print(F), nl )).
exception_record(109,3221225477,140718380167594)
exception_info(109,access,read)
exception_info(109,target,24)
threshold(null_page,65536)
true ;
false.

?- insufficient_memory(committed_memory, I,
                       evidence(P, I, _Fs)),
   selectchk(threshold(large_heap_kb, _), _Fs,
             _Fs1),
   check_finding(user, evidence(P, I, _Fs1), V).
I = heap(2270427086848),
P = 'Insufficient Memory (Committed Memory)',
V = insufficient ;
false.

?- null_pointer_data(T, evidence(P, T, _Fs)),
   selectchk(threshold(null_page, _), _Fs, _Fs1),
   check_finding(user, evidence(P, T, _Fs1), V).
T = 109,
P = 'NULL Pointer (Data)',
V = insufficient ;
false.

?- spiking_thread(102, evidence(P, I, _Fs)),
   _Fs1 = [private_helper(102) | _Fs],
   check_finding(user, evidence(P, I, _Fs1),
                 raises(Leaf, _Error)),
   _Error = existence_error(What, PI).
P = 'Spiking Thread',
I = 102,
Leaf = private_helper(102),
What = procedure,
PI = private_helper/1.
```

```{.prolog .query}
?- derivable([],
             user:thread_time(102, 8450, 1230)).
false.

?- derivable([], thread_time(102, 8450, 1230)).
false.

?- derivable([],
             call(thread_time(102, 8450, 1230))).
false.

?- derivable([], hooked_functions(_, _, _)).
false.

?- hooked_functions(M, H, Fs),
   findall(hooked(F, M, H), member(F, Fs), _Hs),
   derivable(_Hs, hooked_functions(M, H, Fs1)).
M = kernelbase,
H = thirdparty_hook,
Fs = Fs1, Fs1 = ['CreateFileW', 'ReadFile'].

?- catch(derivable([], assertz(seen(102))),
         error(E, _), true).
E = domain_error(derivable_goal, assertz/1).

?- aggregate_all(count, dump_relation(_), R),
   aggregate_all(count, evaluable(_), E).
R = 19,
E = 78.
```

```{.prolog .program}
% has_type(captured_thread, T): a type that a
% loaded file could add to library(error), whose
% clause reads the dump. must_be/2 dispatches
% through this multifile hook.
:- multifile error:has_type/2.

error:has_type(captured_thread, T) :-
    user:thread_time(T, 8450, 1230).

% numlist(Low, High, List) in user: a meta-call
% from the module would reach it before the
% library's.
numlist(_, _, from_user).
```

```{.prolog .query}
?- must_be(captured_thread, 102).
true.

?- catch(derivable([],
                   must_be(captured_thread, 102)),
         error(E, _), true).
E = domain_error(derivable_type, captured_thread).

?- _T = list(captured_thread),
   catch(derivable([], must_be(_T, [102])),
         error(E, _), true).
E = domain_error(derivable_type, captured_thread).

?- derivable([], must_be(oneof([a, b]), a)).
true.

?- catch(derivable([], must_be(oneof([a, b]), c)),
         error(E, _), true).
E = type_error(oneof([a, b]), c).

?- numlist(1, 3, L).
L = from_user.

?- derivable([], numlist(1, 3, L)).
L = [1, 2, 3].

?- freeze(X, user:thread_time(X, 8450, 1230)),
   catch(derivable([], X = 102), error(_E, _),
         true),
   _E = permission_error(Action, Kind, _).
Action = derive,
Kind = attributed_variable,
freeze(X, thread_time(X, 8450, 1230)).
```

```{.prolog .program}
% outcome(Goal, Outcome): true or false for a goal
% that succeeds or fails without binding anything,
% or raises(E) for one that raises E.
outcome(Goal, Outcome) :-
    catch(( \+ \+ Goal
          ->  Outcome = true
          ;   Outcome = false
          ),
          error(E, _),
          Outcome = raises(E)).

% agrees(Type, X): must_be(Type, X) and its
% derivation from an empty list have the same
% outcome, up to variable renaming; otherwise the
% two outcomes are printed.
agrees(Type, X) :-
    outcome(must_be(Type, X), Library),
    outcome(derivable([], must_be(Type, X)),
            Derived),
    (   Library =@= Derived
    ->  true
    ;   format("~q on ~q:~n", [Type, X]),
        report(library, Library),
        report(derived, Derived)
    ).

report(Side, raises(E)) :-
    !,
    format("  ~w raises~n    ~q~n", [Side, E]).
report(Side, Outcome) :-
    format("  ~w ~q~n", [Side, Outcome]).
```

```{.prolog .query}
?- _Cases = [ oneof([a, b])-a, oneof([a, b])-c,
              oneof([f(a)])-f(_), oneof([a])-_,
              between(1, 3)-2, between(1, 3)-2.5,
              between(1, 3)-4,
              between(1.0, 3.0)-2.5,
              nonneg-a, nonneg-(-1), nonneg-0,
              positive_integer-0, integer-_,
              list-[a | _], list-foo,
              list(integer)-[1, a],
              list(integer)-[1 | _],
              list(integer)-[], list(_)-[1],
              atom-1, boolean-maybe, callable-3,
              atomic-f(x), number-x, _-a,
              list(captured_thread)-[],
              list(captured_thread)-[102],
              captured_thread-102 ],
   forall(member(T-X, _Cases), agrees(T, X)).
list(captured_thread) on []:
  library true
  derived raises
    domain_error(derivable_type,captured_thread)
list(captured_thread) on [102]:
  library true
  derived raises
    domain_error(derivable_type,captured_thread)
captured_thread on 102:
  library true
  derived raises
    domain_error(derivable_type,captured_thread)
true.
```

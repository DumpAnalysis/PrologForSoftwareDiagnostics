% 23-11.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 23. Dump Quality, Composition, and Reports: 23.10 The Analysis Report.
% Program block 11 of the chapter.

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

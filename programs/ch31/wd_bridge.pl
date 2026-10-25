% wd_bridge.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 31. Integration: Scripts, Embedding, and Debugger Extensions: 31.7.2 The Schema of Part II over a Snapshot.
% Program block 4 of the chapter; loaded fresh.

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

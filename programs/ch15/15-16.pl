% 15-16.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 15. Memory Dumps as Knowledge Bases: 15.7 The Shared Dump.
% Program block 16 of the chapter.

% invariant(Name): the named invariant of the
% schema holds in the loaded knowledge base.
invariant(frame_module_loaded) :-
    forall(frame(_, _, M, _, _), module(M, _, _)).
invariant(thread_has_time) :-
    forall(thread(T, _), thread_time(T, _, _)).
invariant(thread_has_state) :-
    forall(thread(T, _), thread_state(T, _)).
invariant(thread_has_top_frame) :-
    forall(thread(T, _), frame(T, 0, _, _, _)).
invariant(frames_contiguous) :-
    forall(( frame(T, N, _, _, _), N > 0 ),
           ( N0 is N - 1,
             frame(T, N0, _, _, _)
           )).
invariant(wait_target_listed) :-
    forall(waits_for(_, critical_section, A),
           critical_section(A, _, _, _)).
invariant(owner_is_thread) :-
    forall(( critical_section(_, O, _, _),
             O =\= 0
           ),
           thread(O, _)).
invariant(exception_thread_exists) :-
    forall(exception_record(T, _, _),
           thread(T, _)).

% check_schema: print the name of every invariant
% that does not hold.
check_schema :-
    forall(( clause(invariant(Name), _),
             \+ invariant(Name)
           ),
           format("violated: ~w~n", [Name])).

% 20-08.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 20. Synchronization Patterns: 20.5 Deadlock (Mixed Objects).
% Program block 8 of the chapter.

% deadlock_mixed(-Cycle, -Kinds): Cycle is a cycle
% whose selected edges have more than one kind,
% listed in Kinds.
deadlock_mixed(Cycle, Kinds) :-
    deadlock_witness(any, Cycle, Edges),
    cycle_kinds(Edges, Kinds),
    Kinds = [_, _ | _].

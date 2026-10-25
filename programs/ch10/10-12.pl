% 10-12.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 10. Higher-Order Predicates and Libraries: 10.9 Diagnostic Use.
% Program block 12 of the chapter.

% deadlocked(TID): TID waits, through a chain of
% owners, for a critical section it owns itself.
deadlocked(TID) :-
    wait_for_graph(G),
    transitive_closure(G, Closure),
    member(TID-Reached, Closure),
    memberchk(TID, Reached).

% deadlock_present: the wait-for graph has a
% cycle.
deadlock_present :-
    wait_for_graph(G),
    \+ top_sort(G, _).

% 11-09.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 11. The Dynamic Database, Global State, and Tabling: 11.7 Diagnostic Use.
% Program block 9 of the chapter.

% wait_chain(From, To, Chain): Chain is a shortest
% list of threads from From to To in which each
% thread is blocked by the next.
:- table wait_chain(_, _, lattice(shorter/3)).
wait_chain(From, To, [From, To]) :-
    blocked_by(From, To).
wait_chain(From, To, Chain) :-
    wait_chain(From, Mid, Chain0),
    blocked_by(Mid, To),
    append(Chain0, [To], Chain).

% deadlock_cycle(Cycle): Cycle is a wait chain
% from a thread back to itself.
deadlock_cycle(Cycle) :-
    wait_chain(TID, TID, Cycle).

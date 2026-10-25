% 11-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 11. The Dynamic Database, Global State, and Tabling: 11.6 Tabling.
% Program block 6 of the chapter.

% shorter(P1, P2, P): P is the shorter of the two
% lists P1 and P2, P1 when they are equally long.
shorter(P1, P2, P) :-
    length(P1, L1),
    length(P2, L2),
    (   L1 =< L2
    ->  P = P1
    ;   P = P2
    ).

% route(X, Y, Path): Path is a shortest list of
% vertices from X to Y along edges.
:- table route(_, _, lattice(shorter/3)).
route(X, Y, [X, Y]) :-
    edge(X, Y).
route(X, Y, Path) :-
    route(X, Z, Path0),
    edge(Z, Y),
    append(Path0, [Y], Path).

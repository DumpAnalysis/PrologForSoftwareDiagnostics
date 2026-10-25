% 11-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 11. The Dynamic Database, Global State, and Tabling: 11.6 Tabling.
% Program block 5 of the chapter.

% dist(X, Y, D): D is the length of the shortest
% path from X to Y.
:- table dist(_, _, min).
dist(X, Y, 1) :-
    edge(X, Y).
dist(X, Y, D) :-
    dist(X, Z, D0),
    edge(Z, Y),
    D is D0 + 1.

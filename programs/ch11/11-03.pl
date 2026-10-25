% 11-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 11. The Dynamic Database, Global State, and Tabling: 11.6 Tabling.
% Program block 3 of the chapter.

% edge(X, Y): a small directed graph with a cycle
% a, b, c, a and a tail to d.
edge(a, b).
edge(b, c).
edge(c, a).
edge(c, d).

% reaches(X, Y): Y is reachable from X by one or
% more edges.  The definition of Chapter 4.
:- table reaches/2.
reaches(X, Y) :-
    edge(X, Y).
reaches(X, Y) :-
    edge(X, Z),
    reaches(Z, Y).

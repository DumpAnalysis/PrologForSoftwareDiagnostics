% 11-04.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 11. The Dynamic Database, Global State, and Tabling: 11.6 Tabling.
% Program block 4 of the chapter.

% path(X, Y): as reaches/2, written with the
% recursive goal first.
:- table path/2.
path(X, Y) :-
    path(X, Z),
    edge(Z, Y).
path(X, Y) :-
    edge(X, Y).

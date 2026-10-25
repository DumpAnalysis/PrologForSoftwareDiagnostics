% 07-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 7. Control: 7.2 The Cut.
% Program block 3 of the chapter.

% max_green(X, Y, Max): Max is the larger of X, Y.
max_green(X, Y, X) :-
    X >= Y,
    !.
max_green(X, Y, Y) :-
    X < Y.

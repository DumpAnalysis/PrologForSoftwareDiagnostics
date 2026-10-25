% 07-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 7. Control: 7.2 The Cut.
% Program block 5 of the chapter.

% max_of(X, Y, Max): Max is the larger of X and Y.
max_of(X, Y, Max) :-
    X >= Y,
    !,
    Max = X.
max_of(_, Y, Y).

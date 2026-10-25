% 07-04.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 7. Control: 7.2 The Cut.
% Program block 4 of the chapter.

% max_red(X, Y, Max): Max is the larger of X, Y.
% WRONG: not steadfast.
max_red(X, Y, X) :-
    X >= Y,
    !.
max_red(_, Y, Y).

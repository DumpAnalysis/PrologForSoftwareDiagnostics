% 07-02.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 7. Control: 7.2 The Cut.
% Program block 2 of the chapter.

% max_plain(X, Y, Max): Max is the larger of X, Y.
max_plain(X, Y, X) :-
    X >= Y.
max_plain(X, Y, Y) :-
    X < Y.

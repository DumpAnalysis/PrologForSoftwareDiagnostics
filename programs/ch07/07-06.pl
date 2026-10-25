% 07-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 7. Control: 7.3 If-Then-Else.
% Program block 6 of the chapter.

% larger(X, Y, Max): Max is the larger of X and Y.
larger(X, Y, Max) :-
    (   X >= Y
    ->  Max = X
    ;   Max = Y
    ).

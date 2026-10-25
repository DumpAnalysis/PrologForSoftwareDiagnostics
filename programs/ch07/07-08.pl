% 07-08.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 7. Control: 7.3 If-Then-Else.
% Program block 8 of the chapter.

% pred_or_zero(N, P): P is N - 1, or 0 for N = 0.
pred_or_zero(N, P) :-
    (   N > 0
    ->  succ(P, N)
    ;   P = 0
    ).

% 10-07.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 10. Higher-Order Predicates and Libraries: 10.5 Lambda Expressions.
% Program block 7 of the chapter.

% scale_all(F, Xs, Ys): Ys is Xs with each element
% multiplied by F.
scale_all(F, Xs, Ys) :-
    maplist({F}/[X, Y]>>(Y is X * F), Xs, Ys).

% scale_all_wrong(F, Xs, Ys): as above, with F not
% declared free.
scale_all_wrong(F, Xs, Ys) :-
    maplist([X, Y]>>(Y is X * F), Xs, Ys).

% 10-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 10. Higher-Order Predicates and Libraries: 10.4 Folding.
% Program block 5 of the chapter.

% count_sum(X, N0-S0, N-S): one more element,
% X more in the sum.
count_sum(X, N0-S0, N-S) :-
    N is N0 + 1,
    S is S0 + X.

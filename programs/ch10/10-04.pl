% 10-04.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 10. Higher-Order Predicates and Libraries: 10.4 Folding.
% Program block 4 of the chapter.

% add(X, S0, S): S is S0 plus X.
add(X, S0, S) :-
    S is S0 + X.

% larger(X, M0, M): M is the larger of M0 and X.
larger(X, M0, M) :-
    M is max(M0, X).

% push(X, Xs, [X | Xs]): a step that prepends.
push(X, Xs, [X | Xs]).

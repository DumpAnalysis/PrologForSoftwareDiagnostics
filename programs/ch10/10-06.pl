% 10-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 10. Higher-Order Predicates and Libraries: 10.4 Folding.
% Program block 6 of the chapter.

% add_product(X, Y, S0, S): S is S0 plus X * Y.
add_product(X, Y, S0, S) :-
    S is S0 + X * Y.

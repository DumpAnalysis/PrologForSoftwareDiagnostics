% 29-04.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 29. Meta-Interpreters and Explanation: 29.4 Printing Proofs as Explanations.
% Program block 4 of the chapter.

% portray(+Term): hook. Integers above 0xffff are
% written in hexadecimal.
portray(X) :-
    integer(X),
    X > 0xffff,
    format("0x~16r", [X]).

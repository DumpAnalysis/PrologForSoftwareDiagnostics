% 12-02.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 12. Definite Clause Grammars: 12.2 The Translation.
% Program block 2 of the chapter.

% digit_code(D): one code that is a decimal digit.
digit_code(D) --> [D], { code_type(D, digit) }.

% digit_codes(Ds): one or more digit codes.
digit_codes([D | Ds]) -->
    digit_code(D),
    digit_codes(Ds).
digit_codes([D]) -->
    digit_code(D).

% nat(N): a natural number written in decimal.
nat(N) -->
    digit_codes(Ds),
    { number_codes(N, Ds) }.

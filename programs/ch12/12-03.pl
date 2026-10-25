% 12-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 12. Definite Clause Grammars: 12.2 The Translation.
% Program block 3 of the chapter.

% digit_codes_det(Ds): the longest run of one or
% more digit codes, deterministically.
digit_codes_det([D | Ds]) -->
    digit_code(D),
    (   digit_codes_det(Ds)
    ->  []
    ;   { Ds = [] }
    ).

% nat_det(N): as nat/1, deterministically.
nat_det(N) -->
    digit_codes_det(Ds),
    { number_codes(N, Ds) }.

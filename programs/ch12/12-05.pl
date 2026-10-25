% 12-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 12. Definite Clause Grammars: 12.5 A Frame Line.
% Program block 5 of the chapter.

% addr64(A): a 64-bit address as the debugger
% prints it, two groups of hex digits around `.
addr64(A) -->
    xinteger(Hi), "`", xinteger(Lo),
    { A is Hi << 32 \/ Lo }.

% symbol(M, F, O): the symbol M!F+0xO, or M+0xO
% with F = 'Unknown'.
symbol(M, F, O) -->
    string_without("!+", MC),
    { atom_codes(M, MC) },
    (   "!"
    ->  string_without("+", FC),
        { atom_codes(F, FC) }
    ;   { F = 'Unknown' }
    ),
    "+0x",
    xinteger(O).

% frame_line(TID, Frame): one line of k output for
% thread TID, as a frame/5 term.
frame_line(TID, frame(TID, N, M, F, O)) -->
    xinteger(N), blank,
    addr64(_), blank,
    addr64(_), blank,
    symbol(M, F, O).

% 12-07.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 12. Definite Clause Grammars: 12.5 A Frame Line.
% Program block 7 of the chapter.

% symbol_text(M, F, O): the debugger's text for a
% symbol, for output.
symbol_text(M, F, O) -->
    atom(M),
    (   { F == 'Unknown' }
    ->  []
    ;   "!", atom(F)
    ),
    "+0x", xinteger(O).

% frame_text(Frame): a frame as a numbered line
% without its address columns, for output.
frame_text(frame(_, N, M, F, O)) -->
    { format(codes(NC), "~`0t~16r~2|", [N]) },
    NC, " ",
    symbol_text(M, F, O).

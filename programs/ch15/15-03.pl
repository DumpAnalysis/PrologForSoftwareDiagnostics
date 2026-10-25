% 15-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 15. Memory Dumps as Knowledge Bases: 15.3 From Debugger Output to Facts.
% Program block 3 of the chapter.

:- use_module(library(dcg/basics)).

% k_line(TID, Frame)//: one frame line of kn
% output for thread TID, as a frame/5 term.
k_line(TID, frame(TID, N, M, F, O)) -->
    xinteger(N), blanks,
    address(_ChildSP), blanks,
    address(_RetAddr), blanks,
    symbol(M, F, O), eos.

% address(A)//: a 64-bit address, two hexadecimal
% halves separated by a backquote.
address(A) -->
    xinteger(Hi), "`", xinteger(Lo),
    { A is Hi << 32 \/ Lo }.

% symbol(M, F, O)//: module!function+0xoffset, or
% module+0xoffset for a frame without a symbol.
symbol(M, F, O) -->
    string_without("!+", MC),
    { atom_codes(M0, MC), downcase_atom(M0, M) },
    (   "!"
    ->  string_without("+", FC),
        { atom_codes(F, FC) }
    ;   { F = 'Unknown' }
    ),
    "+0x", xinteger(O).

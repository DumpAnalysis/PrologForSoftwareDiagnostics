% 08-02.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 8. Atoms, Strings, and Term Inspection: 8.5 Diagnostic Use.
% Program block 2 of the chapter.

:- [dump1].

% symbol_parts(Symbol, Module, Function, Offset):
% Symbol is the atom Module!Function+0xOffset, or
% Module+0xOffset for a frame without a symbol.
symbol_parts(Symbol, Module, Function, Offset) :-
    (   sub_atom(Symbol, B, _, A, '!')
    ->  sub_atom(Symbol, 0, B, _, Module),
        sub_atom(Symbol, _, A, 0, Rest),
        name_offset(Rest, Function, Offset)
    ;   name_offset(Symbol, Module, Offset),
        Function = 'Unknown'
    ).

% name_offset(Text, Name, Offset): Text is
% Name+0xOffset, or Name alone with Offset 0.
name_offset(Text, Name, Offset) :-
    (   sub_atom(Text, B, _, A, '+0x')
    ->  sub_atom(Text, 0, B, _, Name),
        sub_atom(Text, _, A, 0, Hex),
        atom_concat('0x', Hex, HexAtom),
        atom_number(HexAtom, Offset)
    ;   Name = Text,
        Offset = 0
    ).

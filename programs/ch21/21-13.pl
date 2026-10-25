% 21-13.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 21. Memory, Heaps, Handles, and Leaks: 21.12 Regular Data.
% Program block 13 of the chapter.

% repeated_byte(Word): the 8-byte Word is one byte
% value repeated eight times.
repeated_byte(Word) :-
    Word >> 8 =:= Word /\ 0x00ff_ffff_ffff_ffff.

% regular_data(TID, Addr): the stack word of TID
% at Addr is a nonzero repeated byte.
regular_data(TID, Addr) :-
    raw_stack(TID, Addr, Word),
    Word =\= 0,
    repeated_byte(Word).

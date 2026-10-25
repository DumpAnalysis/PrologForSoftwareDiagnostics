% 21-11.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 21. Memory, Heaps, Handles, and Leaks: 21.9 Paged Out Data.
% Program block 11 of the chapter.

% unavailable(Base, Size): a range of the address
% space whose contents the dump does not hold.
% An extension of the schema.
unavailable(0x0000_0210_a300_0000, 0x100000).
unavailable(0x0000_7ffb_7a01_0000, 0x4000).

% paged_out_data(Addr): the contents at Addr are
% not in the dump.
paged_out_data(Addr) :-
    unavailable(Base, Size),
    Base =< Addr,
    Addr < Base + Size.

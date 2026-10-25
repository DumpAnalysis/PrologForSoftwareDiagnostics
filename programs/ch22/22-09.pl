% 22-09.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 22. Modules, Versions, and Environment: 22.8 Hidden Module.
% Program block 9 of the chapter.

% code_region(Base, Size): a region of executable
% memory in the address space. An extension of the
% schema.
code_region(0x0000_7ffb_b2a0_0000, 0x1f8000).
code_region(0x0000_7ff6_1d10_0000, 0x3c000).
code_region(0x0000_0210_c000_0000, 0x8000).

% hidden_module(Base, Size): an executable region
% that no loaded module covers.
hidden_module(Base, Size) :-
    code_region(Base, Size),
    \+ ( module(_, ModBase, ModSize),
         ModBase =< Base,
         Base + Size =< ModBase + ModSize
       ).

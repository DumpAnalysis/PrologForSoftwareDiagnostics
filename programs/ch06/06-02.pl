% 06-02.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 6. Arithmetic: 6.6 Formatted Output.
% Program block 2 of the chapter.

% print_address(Addr): print a 64-bit address in
% the debugger's hhhhhhhh`llllllll notation.
print_address(Addr) :-
    High is Addr >> 32,
    Low is Addr /\ 0xffff_ffff,
    format("~`0t~16r~8|`~`0t~16r~9+~n",
           [High, Low]).

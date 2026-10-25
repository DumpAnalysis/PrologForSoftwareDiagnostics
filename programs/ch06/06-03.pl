% 06-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 6. Arithmetic: 6.7 Diagnostic Use.
% Program block 3 of the chapter.

:- [dump1].

% address_module(Addr, Module): Addr lies in the
% address range of Module.
address_module(Addr, Module) :-
    module(Module, Base, Size),
    Base =< Addr,
    Addr < Base + Size.

% print_symbol(Addr): print Addr as module+offset.
print_symbol(Addr) :-
    address_module(Addr, Module),
    module(Module, Base, _),
    Offset is Addr - Base,
    format("~a+0x~16r~n", [Module, Offset]).

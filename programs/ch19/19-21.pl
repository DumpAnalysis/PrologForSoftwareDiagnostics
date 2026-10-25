% 19-21.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 19. Exceptions and Faults: 19.18 Exception Module.
% Program block 21 of the chapter.

% exception_module(TID, Module): the exception of
% TID was raised in Module, or in none.
exception_module(TID, Module) :-
    exception_record(TID, _, Addr),
    (   address_module(Addr, M)
    ->  Module = M
    ;   Module = none
    ).

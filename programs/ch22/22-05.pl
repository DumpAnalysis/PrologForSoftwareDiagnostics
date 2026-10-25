% 22-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 22. Modules, Versions, and Environment: 22.4 No Component Symbols.
% Program block 5 of the chapter.

% no_component_symbols(Module): the debugger had
% no symbol file for Module.
no_component_symbols(Module) :-
    module_info(Module, symbols, Kind),
    Kind \== pdb.

% 02-04.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 2. Terms: 2.11 Diagnostic Use.
% Program block 4 of the chapter.

no_component_symbols(Module) :-
    module_info(Module, symbols, none).

% 02-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 2. Terms: 2.11 Diagnostic Use.
% Program block 5 of the chapter.

unknown_component(Module) :-
    module_info(Module, company, 'Unknown').

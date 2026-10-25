% 22-11.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 22. Modules, Versions, and Environment: 22.10 Virtualized Process (WOW64).
% Program block 11 of the chapter.

% process_info(Key, Value): properties of the
% process. An extension of the schema.
process_info(wow64, false).
process_info(pointer_size, 8).

% virtualized_process: the process runs 32-bit
% code under the system's WOW64 layer, by the
% debugger's report or by the layer's modules.
virtualized_process :-
    (   process_info(wow64, true)
    ;   module(wow64, _, _)
    ).

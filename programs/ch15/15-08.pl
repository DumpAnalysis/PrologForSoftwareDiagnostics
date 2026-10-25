% 15-08.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 15. Memory Dumps as Knowledge Bases: 15.4 Normalization.
% Program block 8 of the chapter.

% module_atom(Text, Module): Module is the schema
% atom for a module the debugger names Text.
module_atom(Text, Module) :-
    file_name_extension(Stem, _, Text),
    downcase_atom(Stem, Module).

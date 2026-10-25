% 22-14.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 22. Modules, Versions, and Environment: 22.13 Top Module.
% Program block 14 of the chapter.

% top_module(TID, Module): the module of the top
% frame of TID.
top_module(TID, Module) :-
    frame(TID, 0, Module, _, _).

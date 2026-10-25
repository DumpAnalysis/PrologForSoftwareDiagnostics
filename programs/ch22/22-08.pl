% 22-08.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 22. Modules, Versions, and Environment: 22.7 Hooked Modules.
% Program block 8 of the chapter.

% hooked_modules(Module): some function of Module
% is hooked.
hooked_modules(Module) :-
    distinct(Module, hooked(_, Module, _)).

% hooking_module(Hooker): Hooker hooks a function
% of some module.
hooking_module(Hooker) :-
    distinct(Hooker, hooked(_, _, Hooker)).

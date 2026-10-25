% 22-07.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 22. Modules, Versions, and Environment: 22.6 Hooked Functions (User Space).
% Program block 7 of the chapter.

% hooked_functions(Module, Hooker, Functions): the
% functions of Module that Hooker hooks.
hooked_functions(Module, Hooker, Functions) :-
    bagof(Function,
          hooked(Function, Module, Hooker),
          Functions).

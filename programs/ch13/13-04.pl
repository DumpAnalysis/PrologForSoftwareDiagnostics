% 13-04.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 13. Programs, Modules, Files, and Tooling: 13.1.1 Meta-Predicates.
% Program block 4 of the chapter.

:- use_module(closures).

% in_module(M, Frame): Frame is in module M.
in_module(M, frame(_, _, M, _, _)).

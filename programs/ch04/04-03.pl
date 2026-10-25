% 04-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 4. Clauses, Queries, and Search: 4.5 The Order of Clauses and Goals.
% Program block 3 of the chapter.

% runs_in_reordered(TID, Module): as runs_in/2,
% with the module looked up first.
runs_in_reordered(TID, Module) :-
    in_module(F, Module),
    top(TID, F).

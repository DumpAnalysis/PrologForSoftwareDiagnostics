% 22-15.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 22. Modules, Versions, and Environment: 22.14 Origin Module.
% Program block 15 of the chapter.

% origin_module(TID, Module): the module of the
% deepest non-system frame of TID.
origin_module(TID, Module) :-
    thread(TID, _),
    aggregate_all(max(N, M),
                  ( frame(TID, N, M, _, _),
                    \+ system_module(M)
                  ),
                  max(_, Module)).

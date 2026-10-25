% 19-22.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 19. Exceptions and Faults: 19.19 Problem Module.
% Program block 22 of the chapter.

% problem_frame(TID, Frame): Frame is the topmost
% frame of TID in a module that is not a system
% module.
problem_frame(TID, frame(TID, N, M, F, O)) :-
    exception_record(TID, _, _),
    aggregate_all(min(N0),
                  ( frame(TID, N0, M0, _, _),
                    module(M0, _, _),
                    \+ system_module(M0)
                  ),
                  N),
    frame(TID, N, M, F, O).

% problem_module(TID, Module): Module is the
% module of the problem frame of TID.
problem_module(TID, Module) :-
    problem_frame(TID, frame(_, _, Module, _, _)).

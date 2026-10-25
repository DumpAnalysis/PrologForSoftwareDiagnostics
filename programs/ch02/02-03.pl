% 02-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 2. Terms: 2.11 Diagnostic Use.
% Program block 3 of the chapter.

% well_formed_frame(TID, N): frame N of thread TID
% has the argument types the schema prescribes.
well_formed_frame(TID, N) :-
    frame(TID, N, Module, Function, Offset),
    integer(TID),
    integer(N),
    atom(Module),
    atom(Function),
    integer(Offset).

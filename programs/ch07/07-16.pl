% 07-16.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 7. Control: 7.7 Diagnostic Use.
% Program block 16 of the chapter.

% well_formed(Frame): Frame is a frame/5 term
% whose arguments have the kinds the schema
% prescribes.
well_formed(frame(TID, N, M, F, O)) :-
    integer(TID),
    integer(N),
    atom(M),
    atom(F),
    integer(O).

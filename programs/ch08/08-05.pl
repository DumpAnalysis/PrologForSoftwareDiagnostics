% 08-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 8. Atoms, Strings, and Term Inspection: 8.5 Diagnostic Use.
% Program block 5 of the chapter.

% unknown_frame(TID, N, Module): frame N of TID is
% in Module and has no resolved function.
unknown_frame(TID, N, Module) :-
    frame(TID, N, Module, 'Unknown', _).

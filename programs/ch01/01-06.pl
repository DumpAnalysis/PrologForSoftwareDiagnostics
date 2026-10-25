% 01-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 1. Logic Programming and Diagnostics: 1.7 Diagnostic Use.
% Program block 6 of the chapter.

not_executing(TID) :-
    thread_state(TID, waiting).
not_executing(TID) :-
    thread_state(TID, suspended).

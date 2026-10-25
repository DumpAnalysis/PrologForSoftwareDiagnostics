% 01-07.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 1. Logic Programming and Diagnostics: 1.7 Diagnostic Use.
% Program block 7 of the chapter.

same_state(TID1, TID2) :-
    thread_state(TID1, State),
    thread_state(TID2, State).

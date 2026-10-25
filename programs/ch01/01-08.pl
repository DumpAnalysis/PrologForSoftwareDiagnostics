% 01-08.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 1. Logic Programming and Diagnostics: 1.7 Diagnostic Use.
% Program block 8 of the chapter.

describe(TID) :-
    thread_state(TID, State),
    write(TID),
    write(' is '),
    write(State),
    nl.

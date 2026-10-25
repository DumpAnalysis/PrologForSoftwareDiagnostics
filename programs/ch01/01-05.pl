% 01-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 1. Logic Programming and Diagnostics: 1.7 Diagnostic Use.
% Program block 5 of the chapter.

active_thread(TID) :-
    thread_state(TID, running).

passive_thread(TID) :-
    thread_state(TID, waiting).

suspended_thread(TID) :-
    thread_state(TID, suspended).

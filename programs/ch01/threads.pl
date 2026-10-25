% threads.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 1. Logic Programming and Diagnostics: 1.7 Diagnostic Use.
% Program block 4 of the chapter.

% thread_state(TID, State): the state of thread
% TID at the time of the dump.  State is one of
% running, waiting, suspended.
thread_state(100, waiting).
thread_state(101, waiting).
thread_state(102, running).
thread_state(103, waiting).
thread_state(107, running).
thread_state(108, suspended).

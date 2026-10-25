% 06-04.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 6. Arithmetic: 6.7 Diagnostic Use.
% Program block 4 of the chapter.

% cpu_time(TID, Ms): the CPU time of TID in
% milliseconds, user and kernel together.
cpu_time(TID, Ms) :-
    thread_time(TID, User, Kernel),
    Ms is User + Kernel.

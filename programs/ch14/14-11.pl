% 14-11.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 14. Constraints and Coroutining: 14.6 Thread Timelines.
% Program block 11 of the chapter.

% deadlock_timeline(A1, R1, A2, R2): the times in
% ms at which 103 acquired section A, 103
% requested section B, 104 acquired B, and 104
% requested A.
deadlock_timeline(A1, R1, A2, R2) :-
    A1 #< R1,
    A2 #< R2,
    A2 #< R1,
    A1 #< R2,
    A1 #>= 2001,
    A2 #>= 2101,
    R1 #=< 9003,
    R2 #=< 9003.

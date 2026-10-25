% 06-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 6. Arithmetic: 6.7 Diagnostic Use.
% Program block 5 of the chapter.

% next_thread(TID, Next): Next is the thread with
% the smallest identifier greater than TID.
next_thread(TID, Next) :-
    thread(Next, _),
    Next > TID,
    \+ ( thread(Other, _),
         Other > TID,
         Other < Next
       ).

% cpu_sum_above(TID, Acc, Total): Total is Acc
% plus the CPU time of every thread above TID.
cpu_sum_above(TID, Acc0, Total) :-
    next_thread(TID, Next),
    cpu_time(Next, Ms),
    Acc is Acc0 + Ms,
    cpu_sum_above(Next, Acc, Total).
cpu_sum_above(TID, Total, Total) :-
    \+ next_thread(TID, _).

% total_cpu(Total): the CPU time of all threads.
total_cpu(Total) :-
    cpu_sum_above(0, 0, Total).

% cpu_share(TID, Percent): the CPU time of TID as
% a percentage of the total.
cpu_share(TID, Percent) :-
    cpu_time(TID, Ms),
    total_cpu(Total),
    Percent is 100.0 * Ms / Total.

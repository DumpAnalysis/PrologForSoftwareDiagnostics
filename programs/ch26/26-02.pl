% 26-02.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 26. Activities and Threads of Activity: 26.1 Thread of Activity.
% Program block 2 of the chapter.

% thread_of_activity(TID, Set): Set is the message
% set of thread TID; with TID unbound, one answer
% per thread.
thread_of_activity(TID, Set) :-
    bagof(N, T^P^C^X^msg(N, T, P, TID, C, X), Ns),
    sort(Ns, Set).

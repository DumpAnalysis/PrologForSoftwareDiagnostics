% 10-02.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 10. Higher-Order Predicates and Libraries: 10.1 Goals as Arguments.
% Program block 2 of the chapter.

% threads_where(Test, TIDs): TIDs is the list of
% threads of the dump for which call(Test, TID)
% succeeds.
threads_where(Test, TIDs) :-
    findall(TID,
            ( thread(TID, _),
              call(Test, TID)
            ),
            TIDs).

% running(TID): TID was running.
running(TID) :-
    thread_state(TID, running).

% blocked(TID): TID waits for a critical section.
blocked(TID) :-
    waits_for(TID, critical_section, _).

% cpu_time(TID, Ms): the CPU time of TID in ms.
cpu_time(TID, Ms) :-
    thread_time(TID, User, Kernel),
    Ms is User + Kernel.

% cpu_above(Ms, TID): TID consumed more than Ms.
cpu_above(Ms, TID) :-
    cpu_time(TID, Total),
    Total > Ms.

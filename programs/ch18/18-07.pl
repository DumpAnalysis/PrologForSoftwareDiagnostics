% 18-07.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 18. Stack Traces and Threads: 18.6 Passive Thread.
% Program block 7 of the chapter.

% passive_thread(TID): TID waits on a user request
% and is not recorded as waiting for an object.
passive_thread(TID) :-
    thread_state(TID, waiting(user_request)),
    \+ waits_for(TID, _, _).

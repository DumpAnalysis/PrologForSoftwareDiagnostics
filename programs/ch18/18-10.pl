% 18-10.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 18. Stack Traces and Threads: 18.9 Active Thread.
% Program block 10 of the chapter.

% active_thread(TID): TID was running when the
% dump was written.
active_thread(TID) :-
    thread_state(TID, running).

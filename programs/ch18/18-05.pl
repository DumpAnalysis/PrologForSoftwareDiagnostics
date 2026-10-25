% 18-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 18. Stack Traces and Threads: 18.4 Main Thread.
% Program block 5 of the chapter.

% entry_function(F): F is an entry function that
% the main thread's stack trace passes through.
entry_function(main).
entry_function(wmain).
entry_function('WinMain').
entry_function('wWinMain').

% main_thread(TID): TID is the main thread.
main_thread(TID) :-
    thread(TID, _),
    once(( frame(TID, _, _, F, _),
           entry_function(F)
         )).

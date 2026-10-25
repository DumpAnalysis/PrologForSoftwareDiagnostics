% 18-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 18. Stack Traces and Threads: 18.5 Special Thread.
% Program block 6 of the chapter.

% special_frame(Function, Role): a frame naming
% Function marks a thread as serving Role.
special_frame('TppWorkerThread', thread_pool).
special_frame('DbgUiRemoteBreakin', debugger).

% special_thread(TID, Role): TID is a thread of
% the system or runtime serving Role.
special_thread(TID, Role) :-
    thread(TID, _),
    frame(TID, _, _, F, _),
    special_frame(F, Role).

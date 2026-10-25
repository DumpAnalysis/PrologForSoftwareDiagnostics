% 26-07.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 26. Activities and Threads of Activity: 26.6 Fiber of Activity.
% Program block 7 of the chapter.

% fiber_of_activity(TID, Key, Fiber): Fiber is the
% non-empty intersection of thread TID's activity
% with the adjoint thread Key.
fiber_of_activity(TID, Key, Fiber) :-
    thread_of_activity(TID, Thread),
    adjoint_thread_of_activity(Key, Adjoint),
    ord_intersection(Thread, Adjoint, Fiber),
    Fiber \== [].

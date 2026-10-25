% 07-11.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 7. Control: 7.7 Diagnostic Use.
% Program block 11 of the chapter.

% thread_class(TID, Class): Class is the one class
% of thread TID, by the first condition to hold.
thread_class(TID, Class) :-
    thread(TID, _),
    class_of(TID, Class).

% class_of(TID, Class): as thread_class/2, for a
% TID known to be a thread of the dump.
class_of(TID, Class) :-
    (   exception_record(TID, _, _)
    ->  Class = faulting
    ;   waits_for(TID, _, _)
    ->  Class = blocked
    ;   thread_state(TID, running)
    ->  Class = running
    ;   thread_state(TID, suspended)
    ->  Class = suspended
    ;   frame(TID, _, ntdll, 'TppWorkerThread', _)
    ->  Class = pool_idle
    ;   Class = waiting
    ).

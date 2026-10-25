% 20-10.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 20. Synchronization Patterns: 20.7 High Contention (Critical Sections).
% Program block 10 of the chapter.

% high_contention(?Addr, -WaiterCount): the
% critical section at Addr reports at least the
% threshold many waiting threads.
high_contention(Addr, WaiterCount) :-
    critical_section(Addr, _, WaiterCount, _),
    threshold(contention, Min),
    WaiterCount >= Min.

% 20-09.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 20. Synchronization Patterns: 20.6 Blocked Queue.
% Program block 9 of the chapter.

% blocked_queue(?Kind, ?Object, -Waiters): at
% least the threshold many threads wait for Object
% of Kind; Waiters lists them.
blocked_queue(Kind, Object, Waiters) :-
    bagof(W, waits(W, Kind, Object), Waiters),
    length(Waiters, N),
    threshold(queue_length, Min),
    N >= Min.

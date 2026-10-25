% 20-12.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 20. Synchronization Patterns: 20.9 Swarm of Shared Locks.
% Program block 12 of the chapter.

% shared_lock_wait(TID, Addr): TID waits on the
% reader-writer lock at Addr. An extension of the
% schema.
shared_lock_wait(125, 0x7ff6_1d13_b000).
shared_lock_wait(126, 0x7ff6_1d13_b000).
shared_lock_wait(127, 0x7ff6_1d13_b000).
shared_lock_wait(128, 0x7ff6_1d13_b000).
shared_lock_wait(129, 0x7ff6_1d13_b000).
shared_lock_wait(130, 0x7ff6_1d13_b040).

% swarm_of_shared_locks(?Addr, -TIDs): at least
% the threshold many threads wait on the lock at
% Addr.
swarm_of_shared_locks(Addr, TIDs) :-
    bagof(T, shared_lock_wait(T, Addr), TIDs),
    length(TIDs, N),
    threshold(swarm_size, Min),
    N >= Min.

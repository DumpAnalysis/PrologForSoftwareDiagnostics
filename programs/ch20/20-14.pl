% 20-14.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 20. Synchronization Patterns: 20.12 Thread Starvation (Normal Priority).
% Program block 14 of the chapter.

% priority(TID, Level): the scheduling priority of
% TID. An extension of the schema.
priority(102, above_normal).
priority(107, above_normal).
priority(100, normal).
priority(101, normal).
priority(103, normal).
priority(104, normal).
priority(105, normal).
priority(106, normal).
priority(108, normal).
priority(109, normal).

% higher_priority(P, Q): level P is above level Q.
higher_priority(above_normal, normal).
higher_priority(high, normal).
higher_priority(high, above_normal).

% cpu_share(TID, Share): the CPU time of TID as a
% percentage of the total, as in Chapter 18.
cpu_share(TID, Share) :-
    thread_time(TID, U, K),
    Ms is U + K,
    aggregate_all(sum(U1 + K1),
                  thread_time(_, U1, K1), Total),
    Total > 0,
    Share is 100.0 * Ms / Total.

% spiking_thread(TID): as in Chapter 18.
spiking_thread(TID) :-
    cpu_share(TID, Share),
    threshold(spiking_share, Min),
    Share >= Min.

% thread_starvation(-TID, -By): TID is a normal
% priority thread not blocked on a recorded object
% and not a pool thread, while By spikes at a
% higher priority.
thread_starvation(TID, By) :-
    priority(TID, normal),
    thread_state(TID, waiting(user_request)),
    \+ waits(TID, _, _),
    \+ frame(TID, _, ntdll, 'TppWorkerThread', _),
    spiking_thread(By),
    priority(By, P),
    higher_priority(P, normal).

% 29-01.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 29. Meta-Interpreters and Explanation: 29.1 Clauses as Data.
% Program block 1 of the chapter.

:- [dump1].
:- use_module(patterns_dump, [threshold/2]).

% blocked_thread(?TID): the dump records an object
% TID waits for.
blocked_thread(TID) :-
    waits_for(TID, _, _).

% owner(?Addr, ?TID): TID owns the critical
% section at Addr.
owner(Addr, TID) :-
    critical_section(Addr, TID, _, _),
    TID =\= 0.

% blocks(?Blocker, ?Blocked): Blocked waits for a
% critical section that Blocker owns.
blocks(Blocker, Blocked) :-
    waits_for(Blocked, critical_section, Addr),
    owner(Addr, Blocker).

% deadlock(?T1, ?T2): T1 and T2 block each other.
deadlock(T1, T2) :-
    blocks(T1, T2),
    blocks(T2, T1),
    T1 < T2.

% cpu_time(?TID, -Ms): the CPU time of TID in ms.
cpu_time(TID, Ms) :-
    thread_time(TID, User, Kernel),
    Ms is User + Kernel.

% total_cpu(-Total): the CPU time of all threads.
total_cpu(Total) :-
    aggregate_all(sum(Ms), cpu_time(_, Ms),
                  Total).

% cpu_share(?TID, -Share): the CPU time of TID as
% a percentage of the total.
cpu_share(TID, Share) :-
    cpu_time(TID, Ms),
    total_cpu(Total),
    Total > 0,
    Share is 100.0 * Ms / Total.

% spiking_thread(?TID): the CPU share of TID is at
% least the threshold.
spiking_thread(TID) :-
    cpu_share(TID, Share),
    threshold(spiking_share, Min),
    Share >= Min.

% handle_leak(?Type): the count of handles of Type
% exceeds the limit for one type.
handle_leak(Type) :-
    handle_count(_, Type, Count),
    threshold(handle_type_count, Max),
    Count > Max.

% 17-01.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 17. The Pattern as a Predicate: 17.2 The Three Forms.
% Program block 1 of the chapter.

:- [dump1].

% threshold(Name, Value): the named threshold used
% by the recognizers of this chapter.
threshold(spiking_share, 25).
threshold(handle_count, 10000).
threshold(frame_repeats, 5).
threshold(null_page, 0x1_0000).

% cpu_time(TID, Ms): the CPU time of TID in ms.
cpu_time(TID, Ms) :-
    thread_time(TID, User, Kernel),
    Ms is User + Kernel.

% total_cpu(Total): the CPU time of all threads.
total_cpu(Total) :-
    aggregate_all(sum(Ms), cpu_time(_, Ms),
                  Total).

% cpu_share(TID, Percent): the CPU time of TID as
% a percentage of the total.
cpu_share(TID, Percent) :-
    cpu_time(TID, Ms),
    total_cpu(Total),
    Percent is 100.0 * Ms / Total.

% spiking_thread(TID, E): TID is a Spiking Thread
% instance, and E is the evidence.
spiking_thread(TID, E) :-
    thread_time(TID, User, Kernel),
    cpu_share(TID, Share),
    threshold(spiking_share, Min),
    Share >= Min,
    E = evidence('Spiking Thread', TID,
        [ thread_time(TID, User, Kernel),
          cpu_share(TID, Share),
          threshold(spiking_share, Min)
        ]).

% spiking_thread(TID): TID is a Spiking Thread
% instance.
spiking_thread(TID) :-
    spiking_thread(TID, _).

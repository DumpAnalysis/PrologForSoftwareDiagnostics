% 21-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 21. Memory, Heaps, Handles, and Leaks: 21.4 Memory Leak (Process Heap).
% Program block 5 of the chapter.

% heap_at(Dump, Heap, ReservedKb, CommittedKb,
% FreeKb): heap/4 of a dump in a series. An
% extension of the schema.
heap_at(dump1a, 0x0000_0210_a000_0000,
        2097152, 1703936, 40960).
heap_at(dump1a, 0x0000_0210_a001_0000,
        1024, 256, 128).
heap_at(dump1a, 0x0000_0210_a200_0000,
        65536, 59392, 2048).
heap_at(dump1b, 0x0000_0210_a000_0000,
        2097152, 1769472, 32768).
heap_at(dump1b, 0x0000_0210_a001_0000,
        1024, 256, 128).
heap_at(dump1b, 0x0000_0210_a200_0000,
        65536, 32768, 4096).
heap_at(dump1, Heap, R, C, F) :-
    heap(Heap, R, C, F).

% dump_time(Dump, Seconds): when each dump of the
% series was written, from the first.
dump_time(dump1a, 0).
dump_time(dump1b, 600).
dump_time(dump1, 1200).

% committed_series(Heap, Series): Series is the
% list of Time-CommittedKb pairs of Heap in time
% order.
committed_series(Heap, Series) :-
    findall(T-C,
            ( heap_at(D, Heap, _, C, _),
              dump_time(D, T)
            ),
            Pairs),
    keysort(Pairs, Series).

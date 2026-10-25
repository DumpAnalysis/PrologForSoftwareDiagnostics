% 23-10.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 23. Dump Quality, Composition, and Reports: 23.9 Step Dumps.
% Program block 10 of the chapter.

% heap_at(Dump, Heap, ReservedKb, CommittedKb,
% FreeKb) and dump_time(Dump, Seconds): the series
% of Chapter 21. An extension of the schema.
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

dump_time(dump1a, 0).
dump_time(dump1b, 600).
dump_time(dump1, 1200).

% step_dumps(Heap, Steps): Steps lists, for each
% dump after the first, Time-Delta where Delta is
% the change of committed KB of Heap since the
% previous dump.
step_dumps(Heap, Steps) :-
    heap(Heap, _, _, _),
    findall(T-C,
            ( heap_at(D, Heap, _, C, _),
              dump_time(D, T)
            ),
            Pairs),
    keysort(Pairs, [_-C0 | Series]),
    steps_from(Series, C0, Steps).

steps_from([], _, []).
steps_from([T-C | Series], Prev, [T-D | Steps]) :-
    D is C - Prev,
    steps_from(Series, C, Steps).

% dump_sequence(Dumps): the dumps in time order.
dump_sequence(Dumps) :-
    findall(T-D, dump_time(D, T), Pairs),
    keysort(Pairs, Sorted),
    pairs_values(Sorted, Dumps).

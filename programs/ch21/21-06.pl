% 21-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 21. Memory, Heaps, Handles, and Leaks: 21.4 Memory Leak (Process Heap).
% Program block 6 of the chapter.

% strictly_increasing(Series): every value is
% greater than the one before it.
strictly_increasing([_-C0 | Pairs]) :-
    increasing_from(Pairs, C0).

% increasing_from(Pairs, Prev): the values of
% Pairs increase, starting above Prev.
increasing_from([], _).
increasing_from([_-C | Pairs], Prev) :-
    Prev < C,
    increasing_from(Pairs, C).

% memory_leak(Heap): the committed size of Heap
% grows at every snapshot, by at least the leak
% threshold over the series.
memory_leak(Heap) :-
    heap(Heap, _, _, _),
    committed_series(Heap, Series),
    Series = [_-First, _ | _],
    strictly_increasing(Series),
    last(Series, _-Last),
    threshold(leak_growth_kb, MinGrowth),
    Last - First >= MinGrowth.

% leak_rate(Heap, KbPerMinute): the mean growth of
% Heap over the series.
leak_rate(Heap, KbPerMinute) :-
    committed_series(Heap, Series),
    Series = [T0-C0 | _],
    last(Series, T1-C1),
    T1 > T0,
    KbPerMinute is (C1 - C0) / (T1 - T0) * 60.

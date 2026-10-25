% 21-07.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 21. Memory, Heaps, Handles, and Leaks: 21.5 Memory Fluctuation.
% Program block 7 of the chapter.

% directions(Series, Dirs): Dirs classifies each
% step of Series as up, down, or flat.
directions([_-C0 | Pairs], Dirs) :-
    directions_from(Pairs, C0, Dirs).

directions_from([], _, []).
directions_from([_-C | Pairs], Prev, [D | Ds]) :-
    compare(Order, C, Prev),
    direction(Order, D),
    directions_from(Pairs, C, Ds).

direction(<, down).
direction(=, flat).
direction(>, up).

% memory_fluctuation(Heap): the committed size of
% Heap both rose and fell over the series.
memory_fluctuation(Heap) :-
    heap(Heap, _, _, _),
    committed_series(Heap, Series),
    directions(Series, Dirs),
    memberchk(up, Dirs),
    memberchk(down, Dirs).

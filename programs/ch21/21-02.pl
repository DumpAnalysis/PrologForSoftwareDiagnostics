% 21-02.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 21. Memory, Heaps, Handles, and Leaks: 21.1 Insufficient Memory (Committed Memory).
% Program block 2 of the chapter.

% committed_ratio(Heap, Ratio): Ratio is the
% committed part of Heap over its reservation.
committed_ratio(Heap, Ratio) :-
    heap(Heap, Reserved, Committed, _),
    Reserved > 0,
    Ratio is Committed / Reserved.

% insufficient_memory(Variant, Instance): the two
% variants of the pattern treated in this chapter.
insufficient_memory(committed_memory, heap(H)) :-
    committed_ratio(H, Ratio),
    threshold(committed_ratio, MinRatio),
    Ratio >= MinRatio,
    heap(H, Reserved, _, _),
    threshold(large_heap_kb, MinKb),
    Reserved >= MinKb.
insufficient_memory(committed_memory, process) :-
    aggregate_all(sum(C), heap(_, _, C, _),
                  Total),
    threshold(committed_total_kb, MaxKb),
    Total >= MaxKb.
insufficient_memory(handle_leak, process(PID)) :-
    process(PID, _),
    aggregate_all(sum(C), handle_count(PID, _, C),
                  Total),
    threshold(handle_total_count, Max),
    Total > Max.

% 21-08.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 21. Memory, Heaps, Handles, and Leaks: 21.6 Dynamic Memory Corruption (Process Heap).
% Program block 8 of the chapter.

% heap_check(Heap, Block, Finding): the result of
% the debugger's heap verification for Block of
% Heap: ok, or the kind of damage found. An
% extension of the schema.
heap_check(0x0000_0210_a200_0000,
           0x0000_0210_a204_1000, ok).
heap_check(0x0000_0210_a200_0000,
           0x0000_0210_a204_1040, bad_size).
heap_check(0x0000_0210_a200_0000,
           0x0000_0210_a204_1080, bad_prev_size).
heap_check(0x0000_0210_a200_0000,
           0x0000_0210_a204_10c0, ok).
heap_check(0x0000_0210_a001_0000,
           0x0000_0210_a001_1000, ok).

% corrupt_entry(Heap, Block, Finding): a block of
% Heap that the verification did not pass.
corrupt_entry(Heap, Block, Finding) :-
    heap_check(Heap, Block, Finding),
    Finding \== ok.

% verified(Heap): the verification examined at
% least one block of Heap.
verified(Heap) :-
    heap(Heap, _, _, _),
    once(heap_check(Heap, _, _)).

% dynamic_memory_corruption(Heap): at least one
% block of Heap did not pass the verification.
dynamic_memory_corruption(Heap) :-
    heap(Heap, _, _, _),
    aggregate_all(count,
                  corrupt_entry(Heap, _, _), N),
    N > 0.

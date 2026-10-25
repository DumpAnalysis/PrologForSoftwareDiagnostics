% 21-09.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 21. Memory, Heaps, Handles, and Leaks: 21.7 Double Free (Process Heap).
% Program block 9 of the chapter.

% heap_op(Seq, Op, Block, TID): the Seq-th
% recorded heap operation, alloc or free of Block
% by thread TID. An extension of the schema: the
% log a heap tracing facility can provide.
heap_op(1, alloc, 0x0000_0210_a204_1040, 102).
heap_op(2, alloc, 0x0000_0210_a204_1080, 102).
heap_op(3, free, 0x0000_0210_a204_1040, 103).
heap_op(4, alloc, 0x0000_0210_a204_10c0, 102).
heap_op(5, free, 0x0000_0210_a204_1040, 104).
heap_op(6, free, 0x0000_0210_a204_1080, 102).
heap_op(7, alloc, 0x0000_0210_a204_1040, 102).
heap_op(8, free, 0x0000_0210_a204_1040, 102).

% log_complete(Relation): the analyst's assumption
% that the extension relation records every
% operation of its kind, with no gaps.
log_complete(heap_op/4).

% no_alloc_between(Block, N1, N2): the log records
% no allocation of Block after operation N1 and
% before operation N2.
no_alloc_between(Block, N1, N2) :-
    \+ ( heap_op(N3, alloc, Block, _),
         N1 < N3,
         N3 < N2
       ).

% double_free_witness(Block, N1, N2): Block was
% freed at N1 and again at N2, N1 < N2, with no
% allocation of Block between them, under the
% assumption that the log is complete.
double_free_witness(Block, N1, N2) :-
    log_complete(heap_op/4),
    heap_op(N1, free, Block, _),
    heap_op(N2, free, Block, _),
    N1 < N2,
    no_alloc_between(Block, N1, N2).

% double_free(Block): some pair of frees of Block
% is a witness.
double_free(Block) :-
    double_free_witness(Block, _, _).

% double_free(Block, Evidence): explainer form,
% built from the witness that was recognized.
double_free(Block, E) :-
    double_free_witness(Block, N1, N2),
    heap_op(N1, free, Block, T1),
    heap_op(N2, free, Block, T2),
    Facts = [ log_complete(heap_op/4),
              heap_op(N1, free, Block, T1),
              heap_op(N2, free, Block, T2),
              no_alloc_between(Block, N1, N2)
            ],
    E = evidence('Double Free (Process Heap)',
                 Block, Facts).

# Chapter 21. Memory, Heaps, Handles, and Leaks

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/21-memory-and-resources.md`.

```{.prolog .program}
:- [dump1].

% pattern(Name, Artifact, Chapter): the catalog
% entries treated in this chapter.
pattern('Insufficient Memory (Committed Memory)',
    memory_dump, 21).
pattern('Handle Leak', memory_dump, 21).
pattern('Insufficient Memory (Handle Leak)',
    memory_dump, 21).
pattern('Memory Leak (Process Heap)',
    memory_dump, 21).
pattern('Memory Fluctuation', memory_dump, 21).
pattern(
    'Dynamic Memory Corruption (Process Heap)',
    memory_dump, 21).
pattern('Double Free (Process Heap)',
    memory_dump, 21).
pattern('Invalid Handle (General)',
    memory_dump, 21).
pattern('Paged Out Data', memory_dump, 21).
pattern('Shared Buffer Overwrite',
    memory_dump, 21).
pattern('Value References', memory_dump, 21).
pattern('Regular Data', memory_dump, 21).
pattern('Data Correlation (Function Parameters)',
    memory_dump, 21).

% threshold(Name, Value): the analyst's limits.
threshold(committed_ratio, 0.85).
threshold(large_heap_kb, 1048576).
threshold(committed_total_kb, 1572864).
threshold(handle_type_count, 5000).
threshold(handle_total_count, 10000).
threshold(leak_growth_kb, 65536).

% print_evidence(Evidence): the pattern name, the
% instance, and one line per supporting fact.
print_evidence(evidence(Name, Instance, Facts)) :-
    format("~a~n  instance: ~q~n",
           [Name, Instance]),
    forall(member(Fact, Facts),
           print_fact(Fact)).

% print_fact(Fact): Fact on one indented line, as
% the toplevel would print it.
print_fact(Fact) :-
    Options = [ quoted(true),
                spacing(next_argument)
              ],
    format("  ~W~n", [Fact, Options]).
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.

?- aggregate_all(count, pattern(_, _, 21), N).
N = 13.

?- threshold(committed_ratio, R).
R = 0.85.
```

## 21.1 Insufficient Memory (Committed Memory)

```{.prolog .program}
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
```

```{.prolog .query}
?- forall(committed_ratio(H, R),
          format("~16r ~3f~n", [H, R])).
210a0000000 0.875
210a0010000 0.250
210a2000000 0.938
true.

?- insufficient_memory(committed_memory, I).
I = heap(2270427086848) ;
I = process.

?- aggregate_all(sum(C), heap(_, _, C, _), T).
T = 1896704.
```

```{.prolog .program}
% variant_name(Variant, Name): the catalog name of
% a variant of Insufficient Memory.
variant_name(committed_memory,
    'Insufficient Memory (Committed Memory)').
variant_name(handle_leak,
    'Insufficient Memory (Handle Leak)').

% insufficient_memory(Variant, Instance, Ev): the
% explainer form for heap instances: the heap and
% the two thresholds the first clause compared it
% with.
insufficient_memory(committed_memory, I, E) :-
    I = heap(H),
    insufficient_memory(committed_memory, I),
    heap(H, R, C, F),
    threshold(committed_ratio, Min),
    threshold(large_heap_kb, MinKb),
    variant_name(committed_memory, Name),
    Facts = [ heap(H, R, C, F),
              threshold(committed_ratio, Min),
              threshold(large_heap_kb, MinKb)
            ],
    E = evidence(Name, I, Facts).
```

```{.prolog .query}
?- forall(insufficient_memory(committed_memory,
                              _, E),
          print_evidence(E)).
Insufficient Memory (Committed Memory)
  instance: heap(2270427086848)
  heap(2270427086848, 2097152, 1835008, 24576)
  threshold(committed_ratio, 0.85)
  threshold(large_heap_kb, 1048576)
true.
```

## 21.2 Handle Leak

```{.prolog .program}
% handle_leak(Type): the count of handles of Type
% exceeds the analyst's limit for one type.
handle_leak(Type) :-
    handle_count(_, Type, Count),
    threshold(handle_type_count, Max),
    Count > Max.

% handle_share(Type, Share): the share of the
% process's handles that are of Type.
handle_share(Type, Share) :-
    handle_count(PID, Type, Count),
    aggregate_all(sum(C), handle_count(PID, _, C),
                  Total),
    Share is Count / Total.
```

```{.prolog .query}
?- handle_leak(Type).
Type = event ;
false.

?- handle_share(event, S), P is round(100 * S).
S = 0.9940554821664465,
P = 99.

?- forall(order_by([desc(C)],
                   handle_count(_, T, C)),
          format("~a~t~10|~t~D~8+~n", [T, C])).
event       12,040
file            38
key             14
thread          10
section          6
mutant           4
true.
```

## 21.3 Insufficient Memory (Handle Leak)

```{.prolog .query}
?- insufficient_memory(handle_leak, I).
I = process(4120).

?- insufficient_memory(V, I).
V = committed_memory,
I = heap(2270427086848) ;
V = committed_memory,
I = process ;
V = handle_leak,
I = process(4120).

?- insufficient_memory(handle_leak, process(P)),
   handle_leak(T).
P = 4120,
T = event ;
false.
```

## 21.4 Memory Leak (Process Heap)

```{.prolog .program}
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
```

```{.prolog .query}
?- committed_series(0x0000_0210_a000_0000, S).
S = [0-1703936, 600-1769472, 1200-1835008].

?- committed_series(0x0000_0210_a200_0000, S).
S = [0-59392, 600-32768, 1200-61440].
```

```{.prolog .program}
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
```

```{.prolog .query}
?- memory_leak(H), format("~16r~n", [H]).
210a0000000
H = 2270427086848 ;
false.

?- leak_rate(0x0000_0210_a000_0000, Rate).
Rate = 6553.6.
```

## 21.5 Memory Fluctuation

```{.prolog .program}
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
```

```{.prolog .query}
?- committed_series(0x0000_0210_a200_0000, S),
   directions(S, D).
S = [0-59392, 600-32768, 1200-61440],
D = [down, up].

?- committed_series(0x0000_0210_a001_0000, S),
   directions(S, D).
S = [0-256, 600-256, 1200-256],
D = [flat, flat].

?- memory_fluctuation(H), format("~16r~n", [H]).
210a2000000
H = 2270460641280.
```

## 21.6 Dynamic Memory Corruption (Process Heap)

```{.prolog .program}
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
```

```{.prolog .query}
?- dynamic_memory_corruption(H),
   format("~16r~n", [H]).
210a2000000
H = 2270460641280.

?- forall(corrupt_entry(_, B, F),
          format("~16r ~a~n", [B, F])).
210a2041040 bad_size
210a2041080 bad_prev_size
true.

?- heap(H, _, _, _), \+ verified(H),
   format("~16r~n", [H]).
210a0000000
H = 2270427086848 ;
false.
```

## 21.7 Double Free (Process Heap)

```{.prolog .program}
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
```

```{.prolog .query}
?- double_free(B), format("~16r~n", [B]).
210a2041040
B = 2270460907584 ;
false.

?- forall(double_free(_, E), print_evidence(E)).
Double Free (Process Heap)
  instance: 2270460907584
  log_complete(heap_op/4)
  heap_op(3, free, 2270460907584, 103)
  heap_op(5, free, 2270460907584, 104)
  no_alloc_between(2270460907584, 3, 5)
true.

?- double_free(B), corrupt_entry(_, B, F).
B = 2270460907584,
F = bad_size ;
false.
```

```{.prolog .query}
?- double_free_witness(B, N1, N2).
B = 2270460907584,
N1 = 3,
N2 = 5 ;
false.

?- double_free_witness(_, 5, 8).
false.

?- double_free(_, evidence(_, _, Fs)),
   member(heap_op(8, _, _, _), Fs).
false.

?- forall(double_free(_, evidence(_, _, Fs)),
          maplist(call, Fs)).
true.
```

## 21.8 Invalid Handle (General)

```{.prolog .program}
% invalid_handle(TID): thread TID raised the
% invalid-handle status or recorded the
% invalid-handle error.
invalid_handle(TID) :-
    thread(TID, _),
    (   exception_record(TID, 0xc0000008, _)
    ;   last_error(TID, 0x6)
    ).
```

```{.prolog .query}
?- invalid_handle(T).
false.

?- last_error(T, C), C =\= 0,
   format("~16r~n", [C]).
3e6
T = 109,
C = 998.
```

## 21.9 Paged Out Data

```{.prolog .program}
% unavailable(Base, Size): a range of the address
% space whose contents the dump does not hold.
% An extension of the schema.
unavailable(0x0000_0210_a300_0000, 0x100000).
unavailable(0x0000_7ffb_7a01_0000, 0x4000).

% paged_out_data(Addr): the contents at Addr are
% not in the dump.
paged_out_data(Addr) :-
    unavailable(Base, Size),
    Base =< Addr,
    Addr < Base + Size.
```

```{.prolog .query}
?- paged_out_data(0x0000_0210_a300_8000).
true ;
false.

?- paged_out_data(0x0000_0210_a204_1040).
false.

?- module(cachelib, Base, _),
   paged_out_data(Base + 0x10000).
Base = 140718060339200.
```

## 21.10 Shared Buffer Overwrite

## 21.11 Value References

```{.prolog .program}
% raw_stack(TID, Addr, Word): the 8-byte Word at
% stack address Addr of thread TID. An extension
% of the schema.
raw_stack(109, 0xe4_1a7f_f6a0, 0x210_a204_1040).
raw_stack(109, 0xe4_1a7f_f6a8, 0x7ffb_8d10_3e8c).
raw_stack(109, 0xe4_1a7f_f6b0, 0x0).
raw_stack(109, 0xe4_1a7f_f6b8, 0x18).
raw_stack(109, 0xe4_1a7f_f6c0, 0x7ff6_1d13_a0c0).
raw_stack(109, 0xe4_1a7f_f6c8, 0x7ffb_b2a1_2f10).
raw_stack(109, 0xe4_1a7f_f6d0,
          0xcdcd_cdcd_cdcd_cdcd).

% reference(Value, Where): Value occurs at Where.
reference(Value, stack(TID, Addr)) :-
    raw_stack(TID, Addr, Value).
reference(Value, critical_section) :-
    critical_section(Value, _, _, _).
reference(Value, exception_target(TID)) :-
    exception_info(TID, target, Value).
reference(Value, heap_block) :-
    distinct(Value, heap_op(_, _, Value, _)).

% value_references(Value, Refs): Refs are the
% places Value occurs, at least two of them.
value_references(Value, Refs) :-
    distinct(Value, reference(Value, _)),
    findall(Where, reference(Value, Where), Refs),
    Refs = [_, _ | _].

% print_references: every value with at least two
% references, one line per reference.
print_references :-
    forall(value_references(V, Refs),
           ( format("~16r~n", [V]),
             forall(member(R, Refs),
                    format("  ~w~n", [R]))
           )).
```

```{.prolog .query}
?- print_references.
210a2041040
  stack(109,979697137312)
  heap_block
18
  stack(109,979697137336)
  exception_target(109)
7ff61d13a0c0
  stack(109,979697137344)
  critical_section
true.
```

## 21.12 Regular Data

```{.prolog .program}
% repeated_byte(Word): the 8-byte Word is one byte
% value repeated eight times.
repeated_byte(Word) :-
    Word >> 8 =:= Word /\ 0x00ff_ffff_ffff_ffff.

% regular_data(TID, Addr): the stack word of TID
% at Addr is a nonzero repeated byte.
regular_data(TID, Addr) :-
    raw_stack(TID, Addr, Word),
    Word =\= 0,
    repeated_byte(Word).
```

```{.prolog .query}
?- repeated_byte(0x4141_4141_4141_4141).
true.

?- repeated_byte(0x4141_4141_4141_4142).
false.

?- regular_data(T, A), raw_stack(T, A, W),
   format("~16r~n", [W]).
cdcdcdcdcdcdcdcd
T = 109,
A = 979697137360,
W = 14829735431805717965.
```

## 21.13 Data Correlation (Function Parameters)

```{.prolog .program}
% frame_param(TID, N, I, Value): the I-th
% parameter of frame N of thread TID as the
% debugger reconstructs it. An extension of the
% schema.
frame_param(109, 0, 1, 0x0).
frame_param(109, 0, 2, 0x0000_0210_a204_1040).
frame_param(109, 0, 3, 0x400).
frame_param(109, 1, 1, 0x0000_0210_a003_2a00).
frame_param(109, 1, 2, 0x0000_0210_a204_1040).
frame_param(109, 2, 1, 0x0000_0210_a003_2a00).

% data_correlation(TID, Param, Relation): the
% value of Param, a parameter of a frame of TID,
% is related to another datum of the dump.
data_correlation(TID, param(N, I), Relation) :-
    exception_info(TID, target, Target),
    frame_param(TID, N, I, Base),
    Offset is Target - Base,
    0 =< Offset,
    Offset < 0x1000,
    Relation = fault_at_offset(Offset).
data_correlation(TID, param(N, I), Relation) :-
    frame_param(TID, N, I, Block),
    corrupt_entry(_, Block, Finding),
    Relation = corrupt_block(Finding).
data_correlation(TID, param(N, I), Relation) :-
    frame_param(TID, N, I, Value),
    frame_param(TID, N2, I2, Value),
    N2 > N,
    Relation = shared_with(param(N2, I2)).
```

```{.prolog .query}
?- data_correlation(109, P, R).
P = param(0, 1),
R = fault_at_offset(24) ;
P = param(0, 2),
R = corrupt_block(bad_size) ;
P = param(1, 2),
R = corrupt_block(bad_size) ;
P = param(0, 2),
R = shared_with(param(1, 2)) ;
P = param(1, 1),
R = shared_with(param(2, 1)) ;
false.

?- frame(109, 0, M, F, _).
M = dbclient,
F = 'Buffer::Copy'.
```

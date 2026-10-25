# Chapter 9. Collecting Solutions and Aggregation

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/09-all-solutions.md`.

## 9.1 Collecting All Solutions

```{.prolog .program}
% event(N, TID, Kind): message N, on thread TID,
% of the given Kind.
event(1, 100, start).
event(2, 101, query).
event(3, 102, query).
event(4, 101, build).
event(5, 101, done).
event(6, 102, warning).
event(7, 102, warning).
event(8, 100, error).
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.

?- findall(K, event(_, 101, K), Ks).
Ks = [query, build, done].

?- findall(N-K, event(N, 102, K), Ps).
Ps = [3-query, 6-warning, 7-warning].

?- findall(K, event(_, 105, K), Ks).
Ks = [].

?- findall(K, event(_, _, K), _Ks),
   length(_Ks, N).
N = 8.
```

```{.prolog .query}
?- findall(X, member(X, [a, b]), L), X = c.
X = c,
L = [a, b].

?- findall(X-Y, member(X, [a, b]), L).
L = [a-_, b-_].
```

```{.prolog .query}
?- findall(K, event(_, 101, K), L, [end]).
L = [query, build, done, end].

?- findall(K, event(_, 101, K), L, T),
   findall(K, event(_, 102, K), T, []).
L = [query, build, done, query, warning, warning],
T = [query, warning, warning].
```

## 9.2 Bags, Sets, and Free Variables

```{.prolog .query}
?- bagof(K, event(N, 101, K), Ks).
N = 2,
Ks = [query] ;
N = 4,
Ks = [build] ;
N = 5,
Ks = [done].

?- bagof(K, event(_, 105, K), Ks).
false.
```

```{.prolog .query}
?- bagof(K, N^event(N, 101, K), Ks).
Ks = [query, build, done].

?- bagof(K, N^event(N, T, K), Ks).
T = 100,
Ks = [start, error] ;
T = 101,
Ks = [query, build, done] ;
T = 102,
Ks = [query, warning, warning].
```

```{.prolog .query}
?- bagof(K, event(_, 101, K), Ks).
Ks = [query] ;
Ks = [build] ;
Ks = [done].
```

```{.prolog .query}
?- setof(K, N^T^event(N, T, K), Ks).
Ks = [build, done, error, query, start, warning].

?- setof(T, N^K^event(N, T, K), Ts).
Ts = [100, 101, 102].

?- setof(K, N^event(N, T, K), Ks).
T = 100,
Ks = [error, start] ;
T = 101,
Ks = [build, done, query] ;
T = 102,
Ks = [query, warning].
```

## 9.3 Aggregation

```{.prolog .query}
?- aggregate_all(count, event(_, 101, _), N).
N = 3.

?- aggregate_all(count, event(_, 105, _), N).
N = 0.

?- aggregate_all(sum(N), event(N, 101, _), S).
S = 11.

?- aggregate_all(max(N), event(N, 102, _), M).
M = 7.

?- aggregate_all(max(N), event(N, 105, _), M).
false.

?- aggregate_all(max(N, K), event(N, 101, K), M).
M = max(5, done).

?- aggregate_all(set(K), event(_, 102, K), Ks).
Ks = [query, warning].
```

```{.prolog .query}
?- aggregate(count, N^K^event(N, T, K), C).
T = 100,
C = 2 ;
T = 101,
C = 3 ;
T = 102,
C = 3.

?- aggregate(count, N^event(N, T, K), C).
T = 100,
K = error,
C = 1 ;
T = 100,
K = start,
C = 1 ;
T = 101,
K = build,
C = 1 ;
T = 101,
K = done,
C = 1 ;
T = 101,
K = query,
C = 1 ;
T = 102,
K = query,
C = 1 ;
T = 102,
K = warning,
C = 2.
```

```{.prolog .query}
?- forall(event(_, T, _), T >= 100).
true.

?- aggregate_all(count, (event(_, T, _), T < 100),
   N).
N = 0.
```

## 9.4 Solution Sequences

```{.prolog .query}
?- distinct(T, event(_, T, _)).
T = 100 ;
T = 101 ;
T = 102 ;
false.

?- distinct(K, event(_, _, K)).
K = start ;
K = query ;
K = build ;
K = done ;
K = warning ;
K = error.
```

```{.prolog .query}
?- limit(2, event(N, T, K)).
N = 1,
T = 100,
K = start ;
N = 2,
T = 101,
K = query.

?- limit(2, offset(1, event(N, _, _))).
N = 2 ;
N = 3.

?- order_by([desc(N)], event(N, 102, K)).
N = 7,
K = warning ;
N = 6,
K = warning ;
N = 3,
K = query.

?- call_nth(event(N, _, _), 3).
N = 3.
```

```{.prolog .query}
?- group_by(T, K, event(_, T, K), Ks).
T = 100,
Ks = [start, error] ;
T = 101,
Ks = [query, build, done] ;
T = 102,
Ks = [query, warning, warning].
```

## 9.5 Pairs and Sorting

```{.prolog .query}
?- pairs_keys_values(P, [a, b], [1, 2]).
P = [a-1, b-2].

?- pairs_keys_values([a-1, b-2], Ks, Vs).
Ks = [a, b],
Vs = [1, 2].

?- pairs_values([a-1, b-2], Vs).
Vs = [1, 2].

?- transpose_pairs([a-1, b-2, c-1], T).
T = [1-a, 1-c, 2-b].
```

```{.prolog .query}
?- keysort([b-1, a-2, b-0, a-1], S).
S = [a-2, a-1, b-1, b-0].

?- msort([b-1, a-2, b-0, a-1], S).
S = [a-1, a-2, b-0, b-1].

?- sort(1, @>=, [b-1, a-2, b-0, a-1], S).
S = [b-1, b-0, a-2, a-1].

?- sort(1, @>, [b-1, a-2, b-0, a-1], S).
S = [b-1, a-2].
```

```{.prolog .program}
% by_count_desc(Order, K1-N1, K2-N2): order pairs
% by count descending, then by key ascending.
by_count_desc(Order, K1-N1, K2-N2) :-
    compare(Order0, N2, N1),
    (   Order0 == (=)
    ->  compare(Order, K1, K2)
    ;   Order = Order0
    ).
```

```{.prolog .query}
?- predsort(by_count_desc,
   [query-2, build-1, warning-2, done-1], S).
S = [query-2, warning-2, build-1, done-1].
```

```{.prolog .program}
% run_counts(Sorted, Counts): Counts is a list of
% X-N pairs, one per run of N identical elements X
% in the sorted list Sorted.
run_counts([], []).
run_counts([X | Xs], [X-N | Counts]) :-
    run_length(Xs, X, 1, N, Rest),
    run_counts(Rest, Counts).

% run_length(Xs, X, N0, N, Rest): N is N0 plus the
% leading elements of Xs identical to X; Rest is
% what follows them.
run_length(Xs, X, N0, N, Rest) :-
    (   Xs = [Y | Xs1],
        Y == X
    ->  N1 is N0 + 1,
        run_length(Xs1, X, N1, N, Rest)
    ;   N = N0,
        Rest = Xs
    ).

% histogram(Values, Counts): Counts is the list of
% Value-Count pairs of Values, most frequent
% first.
histogram(Values, Counts) :-
    msort(Values, Sorted),
    run_counts(Sorted, Counts0),
    predsort(by_count_desc, Counts0, Counts).
```

```{.prolog .query}
?- histogram([b, a, c, a, b, a], H).
H = [a-3, b-2, c-1].

?- findall(K, event(_, _, K), _Ks),
   histogram(_Ks, _H),
   forall(member(K-N, _H),
          format("~a ~d~n", [K, N])).
query 2
warning 2
build 1
done 1
error 1
start 1
true.
```

## 9.6 Diagnostic Use

```{.prolog .program}
:- [dump1].
:- [trace1].
```

```{.prolog .program}
% stack_trace(TID, Frames): Frames is the list of
% frame/5 terms of thread TID, top frame first.
stack_trace(TID, Frames) :-
    findall(frame(TID, N, M, F, O),
            frame(TID, N, M, F, O),
            Frames0),
    sort(2, @=<, Frames0, Frames).
```

```{.prolog .query}
?- stack_trace(109, _Frames), length(_Frames, N).
N = 7.

?- stack_trace(999, Frames).
Frames = [].
```

```{.prolog .program}
% stack_trace_collection(Collection): Collection
% is the list of TID-Frames pairs, one per thread.
stack_trace_collection(Collection) :-
    findall(TID-Frames,
            ( thread(TID, _),
              stack_trace(TID, Frames)
            ),
            Collection).

% print_depths(Collection): one line per thread
% with the depth of its stack trace.
print_depths(Collection) :-
    forall(member(TID-Frames, Collection),
           ( length(Frames, Depth),
             format("~d~t~6|~t~d~4+~n",
                    [TID, Depth])
           )).
```

```{.prolog .query}
?- stack_trace_collection(_C), length(_C, N).
N = 10.

?- stack_trace_collection(_C), print_depths(_C).
100      7
101     10
102      7
103     10
104     10
105      4
106      4
107     14
108      5
109      7
true.

?- stack_trace_collection(_C),
   aggregate_all(sum(D),
   ( member(_-Fs, _C), length(Fs, D) ), Total).
Total = 78.
```

```{.prolog .program}
% module_variety(Count): Count is the number of
% modules loaded in the process.
module_variety(Count) :-
    aggregate_all(count, module(_, _, _), Count).
```

```{.prolog .query}
?- module_variety(N).
N = 10.

?- aggregate_all(set(M), frame(_, _, M, _, _),
   _Ms), length(_Ms, N).
N = 8.

?- aggregate_all(set(C),
   module_info(_, company, C), Cs).
Cs = ['CacheWorks', 'Example Corp', 'Unknown'].

?- setof(M, T^N^F^O^frame(T, N, M, F, O), _Ms),
   module_variety(Total), length(_Ms, OnStack),
   Idle is Total - OnStack.
Total = 10,
OnStack = 8,
Idle = 2.
```

```{.prolog .query}
?- findall(M, frame(_, _, M, _, _), _Ms),
   histogram(_Ms, _H),
   forall(member(M-N, _H),
          format("~a~t~14|~t~d~4+~n", [M, N])).
ntdll           28
appserver       13
reportengine    13
kernel32        10
ucrtbase         6
dbclient         5
kernelbase       2
cachelib         1
true.
```

```{.prolog .program}
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
```

```{.prolog .query}
?- total_cpu(Total).
Total = 14135.

?- aggregate_all(max(Ms, TID), cpu_time(TID, Ms),
   M).
M = max(9680, 102).

?- limit(3, order_by([desc(Ms)],
   cpu_time(TID, Ms))).
Ms = 9680,
TID = 102 ;
Ms = 4100,
TID = 107 ;
Ms = 160,
TID = 100.
```

```{.prolog .program}
% print_cpu_table: one row per thread, largest
% share first.
print_cpu_table :-
    forall(order_by([desc(Ms)], cpu_time(T, Ms)),
           print_cpu_row(T, Ms)).

% print_cpu_row(TID, Ms): one table row for TID.
print_cpu_row(TID, Ms) :-
    cpu_share(TID, Percent),
    format("~d~t~6|~t~D~8+ ms~3+~t~1f~8+%~n",
           [TID, Ms, Percent]).
```

```{.prolog .query}
?- print_cpu_table.
102      9,680 ms    68.5%
107      4,100 ms    29.0%
100        160 ms     1.1%
109         60 ms     0.4%
103         40 ms     0.3%
104         35 ms     0.2%
105         25 ms     0.2%
101         20 ms     0.1%
106         15 ms     0.1%
108          0 ms     0.0%
true.
```

```{.prolog .query}
?- bagof(TID, waits_for(TID, critical_section, A),
   TIDs), format("~16r~n", [A]).
7ff61d13a0c0
A = 140695026507968,
TIDs = [101, 104] ;
7ff61d13a140
A = 140695026508096,
TIDs = [103].
```

```{.prolog .program}
% message_word(Word): Word is a lowercased word of
% the text of some message of the trace.
message_word(Word) :-
    msg(_, _, _, _, _, Text),
    split_string(Text, " ,:=", " ,:=", Parts),
    member(Part, Parts),
    string_lower(Part, Word).

% word_count(Word, Count): Word occurs Count times
% in the trace.
word_count(Word, Count) :-
    aggregate_all(count, message_word(Word),
                  Count).

% vocabulary(Index): Index is the list of
% Word-Count pairs of the trace, most frequent
% first.
vocabulary(Index) :-
    findall(Word, message_word(Word), Words),
    histogram(Words, Index).
```

```{.prolog .query}
?- aggregate_all(count, message_word(_), N).
N = 378.

?- vocabulary(_V), length(_V, N).
N = 123.

?- vocabulary(_V),
   forall(limit(8, member(W-N, _V)),
          format("~t~d~4| ~s~n", [N, W])).
  28 request
  21 worker
  13 ms
  11 received
  11 to
  10 start
   9 dispatched
   9 get
true.

?- word_count("error", N).
N = 4.

?- word_count("session", N).
N = 6.
```

```{.prolog .program}
% rare_word(Word): Word occurs once in the trace
% and begins with a lowercase letter.
rare_word(Word) :-
    vocabulary(Index),
    member(Word-1, Index),
    string_code(1, Word, C),
    C >= 0'a,
    C =< 0'z.

% print_columns(Words): print Words three to a
% line in 16-character columns.
print_columns(Words) :-
    forall(nth1(I, Words, W),
           ( Stop is 16 * ((I - 1) mod 3 + 1),
             format("~s~t~*|", [W, Stop]),
             (   I mod 3 =:= 0
             ->  nl
             ;   true
             )
           )),
    nl.
```

```{.prolog .query}
?- vocabulary(_V),
   findall(W, member(W-1, _V), _Once),
   length(_Once, N).
N = 62.

?- findall(W, rare_word(W), _Rare),
   length(_Rare, N).
N = 31.

?- findall(W, rare_word(W), _Rare),
   print_columns(_Rare).
buffer          busy            c
cache           capacity        code
commit          configuration   connected
connecting      copy            cpu
exception       failed          initialized
loading         lookup          pool
post            receive         reply
send            started         starting
stopping        thread          threads
unhandled       version         watchdog
workers
true.
```

```{.prolog .query}
?- aggregate(count,
   N^T^P^Th^Tx^msg(N, T, P, Th, C, Tx), Count).
C = appserver,
Count = 47 ;
C = cachelib,
Count = 1 ;
C = dbclient,
Count = 12 ;
C = reportengine,
Count = 11.
```

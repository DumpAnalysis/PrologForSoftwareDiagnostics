# Chapter 10. Higher-Order Predicates and Libraries

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/10-higher-order.md`.

## 10.1 Goals as Arguments

```{.prolog .program}
:- [dump1].
:- use_module(library(apply)).
:- use_module(library(yall)).
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.

?- call(thread_time, 102, U, K).
U = 8450,
K = 1230.

?- call(thread_time(102), U, K).
U = 8450,
K = 1230.

?- call(thread_time(102, U), K).
U = 8450,
K = 1230.

?- G = thread_time(102), call(G, U, K).
G = thread_time(102),
U = 8450,
K = 1230.
```

```{.prolog .query}
?- G =.. [thread_time, 102, U, K], call(G).
G = thread_time(102, 8450, 1230),
U = 8450,
K = 1230.

?- catch(call(_, 1), error(E, _), true).
E = instantiation_error.

?- catch(call(1), error(E, _), true).
E = type_error(callable, 1).

?- catch(call(foo, 1), error(E, _), true).
E = existence_error(procedure, foo/1).
```

```{.prolog .program}
% threads_where(Test, TIDs): TIDs is the list of
% threads of the dump for which call(Test, TID)
% succeeds.
threads_where(Test, TIDs) :-
    findall(TID,
            ( thread(TID, _),
              call(Test, TID)
            ),
            TIDs).

% running(TID): TID was running.
running(TID) :-
    thread_state(TID, running).

% blocked(TID): TID waits for a critical section.
blocked(TID) :-
    waits_for(TID, critical_section, _).

% cpu_time(TID, Ms): the CPU time of TID in ms.
cpu_time(TID, Ms) :-
    thread_time(TID, User, Kernel),
    Ms is User + Kernel.

% cpu_above(Ms, TID): TID consumed more than Ms.
cpu_above(Ms, TID) :-
    cpu_time(TID, Total),
    Total > Ms.
```

```{.prolog .query}
?- threads_where(running, Ts).
Ts = [102, 107].

?- threads_where(blocked, Ts).
Ts = [101, 103, 104].

?- threads_where(cpu_above(1000), Ts).
Ts = [102, 107].

?- threads_where(cpu_above(100), Ts).
Ts = [100, 102, 107].
```

## 10.2 Mapping Lists

```{.prolog .query}
?- maplist(succ, [0, 1], L).
L = [1, 2].

?- maplist(succ, L, [1, 2]).
L = [0, 1].

?- maplist(succ, [0, 1], [1]).
false.

?- maplist(thread_state, [100, 102, 108], Ss).
Ss = [waiting(user_request), running, suspended].

?- maplist(thread_time, [100, 102], Us, Ks).
Us = [120, 8450],
Ks = [40, 1230].

?- maplist(cpu_time, [100, 101, 102], Ms).
Ms = [160, 20, 9680].
```

```{.prolog .query}
?- maplist(cpu_above(10), [100, 102, 107]).
true.

?- maplist(cpu_above(10), [100, 108]).
false.

?- length(L, 3), maplist(=(0), L).
L = [0, 0, 0].

?- maplist(=(X), [1, 1, 1]).
X = 1.

?- maplist(=(X), [1, 2]).
false.
```

```{.prolog .query}
?- maplist(cpu_time, Ts, [160, 20]).
Ts = [100, 101] ;
false.

?- maplist(member, [X, Y], [[a, b], [c]]).
X = a,
Y = c ;
X = b,
Y = c.
```

## 10.3 Filtering and Partitioning

```{.prolog .query}
?- exclude(==(ntdll), [ntdll, kernel32, ntdll,
   appserver], Rest).
Rest = [kernel32, appserver].

?- include(==(ntdll), [ntdll, kernel32, ntdll,
   appserver], Kept).
Kept = [ntdll, ntdll].

?- findall(T, thread(T, _), _Ts),
   include(blocked, _Ts, Blocked).
Blocked = [101, 103, 104].

?- findall(T, thread(T, _), _Ts),
   exclude(cpu_above(100), _Ts, Quiet).
Quiet = [101, 103, 104, 105, 106, 108, 109].
```

```{.prolog .program}
% cpu_order(Threshold, TID, Order): Order is the
% order of TID's CPU time relative to Threshold.
cpu_order(Threshold, TID, Order) :-
    cpu_time(TID, Ms),
    compare(Order, Ms, Threshold).
```

```{.prolog .query}
?- findall(T, thread(T, _), _Ts),
   partition(running, _Ts, Running, Others).
Running = [102, 107],
Others = [100, 101, 103, 104, 105, 106, 108, 109].

?- findall(T, thread(T, _), _Ts),
   partition(cpu_order(40), _Ts,
             Below, At, Above).
Below = [101, 104, 105, 106, 108],
At = [103],
Above = [100, 102, 107, 109].
```

## 10.4 Folding

```{.prolog .program}
% add(X, S0, S): S is S0 plus X.
add(X, S0, S) :-
    S is S0 + X.

% larger(X, M0, M): M is the larger of M0 and X.
larger(X, M0, M) :-
    M is max(M0, X).

% push(X, Xs, [X | Xs]): a step that prepends.
push(X, Xs, [X | Xs]).
```

```{.prolog .query}
?- foldl(add, [1, 2, 3], 0, S).
S = 6.

?- foldl(add, [], 0, S).
S = 0.

?- foldl(larger, [3, 9, 2], 0, M).
M = 9.

?- foldl(push, [a, b, c], [], R).
R = [c, b, a].
```

```{.prolog .program}
% count_sum(X, N0-S0, N-S): one more element,
% X more in the sum.
count_sum(X, N0-S0, N-S) :-
    N is N0 + 1,
    S is S0 + X.
```

```{.prolog .query}
?- foldl(count_sum, [10, 20, 30], 0-0, N-S).
N = 3,
S = 60.

?- findall(T, thread(T, _), _Ts),
   maplist(cpu_time, _Ts, _Ms),
   foldl(count_sum, _Ms, 0-0, N-S),
   Mean is S / N.
N = 10,
S = 14135,
Mean = 1413.5.
```

```{.prolog .program}
% add_product(X, Y, S0, S): S is S0 plus X * Y.
add_product(X, Y, S0, S) :-
    S is S0 + X * Y.
```

```{.prolog .query}
?- foldl(add_product, [1, 2, 3], [4, 5, 6], 0, S).
S = 32.
```

## 10.5 Lambda Expressions

```{.prolog .query}
?- call([X, Y]>>(Y is X * X), 4, R).
R = 16.

?- foldl([X, S0, S]>>(S is S0 + X),
   [1, 2, 3], 0, S).
S = 6.

?- maplist([T, T-Ms]>>cpu_time(T, Ms),
   [100, 102], Pairs).
Pairs = [100-160, 102-9680].

?- include([T]>>(cpu_time(T, Ms), Ms > 1000),
   [100, 102, 107], Busy).
Busy = [102, 107].
```

```{.prolog .query}
?- maplist([X]>>(Y = X), [1]), var(Y).
true.

?- maplist({Y}/[X]>>(Y = X), [1]).
Y = 1.
```

```{.prolog .program}
% scale_all(F, Xs, Ys): Ys is Xs with each element
% multiplied by F.
scale_all(F, Xs, Ys) :-
    maplist({F}/[X, Y]>>(Y is X * F), Xs, Ys).

% scale_all_wrong(F, Xs, Ys): as above, with F not
% declared free.
scale_all_wrong(F, Xs, Ys) :-
    maplist([X, Y]>>(Y is X * F), Xs, Ys).
```

```{.prolog .query}
?- scale_all(3, [1, 2], L).
L = [3, 6].

?- catch(scale_all_wrong(3, [1, 2], L),
   error(E, _), true).
E = instantiation_error.

?- F = 3,
   maplist([X, Y]>>(Y is X * F), [1, 2], L).
F = 3,
L = [3, 6].
```

```{.prolog .query}
?- setof(T, {T}/thread_state(T, waiting(_)), Ts).
Ts = [100, 101, 103, 104, 105, 106, 109].
```

## 10.6 Association Lists

```{.prolog .query}
?- list_to_assoc([101-blocked, 102-running], _A),
   get_assoc(102, _A, Class).
Class = running.

?- list_to_assoc([101-blocked, 102-running], _A),
   get_assoc(105, _A, Class).
false.

?- list_to_assoc([b-2, a-1, c-3], _A),
   assoc_to_list(_A, L),
   assoc_to_keys(_A, Ks),
   assoc_to_values(_A, Vs).
L = [a-1, b-2, c-3],
Ks = [a, b, c],
Vs = [1, 2, 3].

?- catch(list_to_assoc([a-1, a-2], _A),
   error(E, _), true).
E = domain_error(unique_key_pairs, [a-1, a-2]).
```

```{.prolog .query}
?- empty_assoc(_A0),
   put_assoc(k, _A0, 1, _A1),
   put_assoc(k, _A1, 2, _A2),
   get_assoc(k, _A1, V1),
   get_assoc(k, _A2, V2).
V1 = 1,
V2 = 2.
```

```{.prolog .program}
% count_into(Key, A0, A): A is A0 with the count
% of Key increased by one, or set to 1 if absent.
count_into(Key, A0, A) :-
    (   get_assoc(Key, A0, N0)
    ->  N is N0 + 1
    ;   N = 1
    ),
    put_assoc(Key, A0, N, A).

% module_counts(Counts): Counts is the list of
% Module-N pairs, N the number of frames in Module
% over all stack traces of the dump, by module.
module_counts(Counts) :-
    findall(M, frame(_, _, M, _, _), Ms),
    empty_assoc(A0),
    foldl(count_into, Ms, A0, A),
    assoc_to_list(A, Counts).
```

```{.prolog .query}
?- module_counts(_Counts),
   forall(member(M-N, _Counts),
          format("~a~t~14|~t~d~4+~n", [M, N])).
appserver       13
cachelib         1
dbclient         5
kernel32        10
kernelbase       2
ntdll           28
reportengine    13
ucrtbase         6
true.
```

## 10.7 Dicts

```{.prolog .query}
?- D = thread{tid: 102, cpu: 9680}.
D = thread{cpu:9680, tid:102}.

?- thread{cpu: 9680, tid: 102} ==
   thread{tid: 102, cpu: 9680}.
true.

?- thread{tid: 102} = thread{tid: 102, cpu: 9680}.
false.

?- thread{tid: T} :< thread{tid: 102, cpu: 9680}.
T = 102.
```

```{.prolog .query}
?- get_dict(cpu, thread{tid: 102, cpu: 9680}, V).
V = 9680.

?- get_dict(state, thread{tid: 102, cpu: 9680},
   V).
false.

?- put_dict(cpu, thread{tid: 102}, 9680, D).
D = thread{cpu:9680, tid:102}.

?- dict_pairs(D, thread, [tid-102, cpu-9680]).
D = thread{cpu:9680, tid:102}.

?- dict_pairs(thread{tid: 102, cpu: 9680},
   Tag, Ps).
Tag = thread,
Ps = [cpu-9680, tid-102].
```

```{.prolog .program}
% thread_record(TID, Record): Record is a dict
% with the identifier, state, and CPU time of TID.
thread_record(TID, Record) :-
    Record = thread{tid: TID, state: S, cpu: Ms},
    thread_state(TID, S),
    cpu_time(TID, Ms).

% busy(Record): the thread consumed more than a
% second of CPU time.
busy(Record) :-
    Record.cpu > 1000.

% record_state(Record, State): State is the state
% field of Record.
record_state(Record, State) :-
    State = Record.state.
```

```{.prolog .query}
?- thread_record(102, R).
R = thread{cpu:9680, state:running, tid:102}.

?- thread_record(102, R), X = R.cpu.
R = thread{cpu:9680, state:running, tid:102},
X = 9680.

?- thread_record(101, _R), record_state(_R, S).
S = waiting(user_request).

?- findall(T, thread(T, _), _Ts),
   maplist(thread_record, _Ts, _Rs),
   include(busy, _Rs, _Busy),
   maplist([R, T]>>get_dict(tid, R, T),
           _Busy, Ts).
Ts = [102, 107].

?- thread_record(102, _R),
   catch(X = _R.owner,
         error(existence_error(key, K, _), _),
         true).
K = owner.

?- thread_record(102, _R),
   X = _R.get(owner, none).
X = none.
```

## 10.8 Graphs

```{.prolog .query}
?- vertices_edges_to_ugraph([d], [a-b, b-c], G).
G = [a-[b], b-[c], c-[], d-[]].

?- vertices_edges_to_ugraph([], [a-b, b-c], G),
   vertices(G, Vs), edges(G, Es),
   neighbours(b, G, Ns).
G = [a-[b], b-[c], c-[]],
Vs = [a, b, c],
Es = [a-b, b-c],
Ns = [c].

?- vertices_edges_to_ugraph([], [a-b, b-c], G),
   reachable(a, G, R1), reachable(c, G, R2).
G = [a-[b], b-[c], c-[]],
R1 = [a, b, c],
R2 = [c].

?- vertices_edges_to_ugraph([], [a-b, b-c], G),
   transitive_closure(G, C).
G = [a-[b], b-[c], c-[]],
C = [a-[b, c], b-[c], c-[]].

?- vertices_edges_to_ugraph([], [a-b, b-c], G),
   top_sort(G, Order).
G = [a-[b], b-[c], c-[]],
Order = [a, b, c].
```

```{.prolog .query}
?- vertices_edges_to_ugraph([], [a-b, b-c, c-a],
   G), top_sort(G, Order).
false.

?- vertices_edges_to_ugraph([], [a-b, b-c, c-a],
   G), transitive_closure(G, C).
G = [a-[b], b-[c], c-[a]],
C = [a-[a, b, c], b-[a, b, c], c-[a, b, c]].

?- vertices_edges_to_ugraph([], [a-b, b-c], G),
   transpose_ugraph(G, T), reachable(c, T, R).
G = [a-[b], b-[c], c-[]],
T = [a-[], b-[a], c-[b]],
R = [a, b, c].
```

## 10.9 Diagnostic Use

```{.prolog .program}
% blocked_by(Waiter, Owner): Waiter waits for a
% critical section that Owner owns.
blocked_by(Waiter, Owner) :-
    waits_for(Waiter, critical_section, Addr),
    critical_section(Addr, Owner, _, _),
    Owner \== 0.

% wait_for_graph(Graph): Graph is the ugraph whose
% edges are the blocked_by/2 pairs of the dump.
wait_for_graph(Graph) :-
    findall(W-O, blocked_by(W, O), Edges),
    vertices_edges_to_ugraph([], Edges, Graph).
```

```{.prolog .query}
?- wait_for_graph(G).
G = [101-[103], 103-[104], 104-[103]].

?- wait_for_graph(_G),
   vertices(_G, Vs), edges(_G, Es).
Vs = [101, 103, 104],
Es = [101-103, 103-104, 104-103].
```

```{.prolog .program}
% reached_from(V, G, Others): Others are the
% vertices reachable from V in G, other than V;
% [] when V is not a vertex of G.
reached_from(V, G, Others) :-
    (   reachable(V, G, Reached)
    ->  subtract(Reached, [V], Others)
    ;   Others = []
    ).

% waits_on(TID, Others): Others are the threads
% TID waits for, directly or through a chain.
waits_on(TID, Others) :-
    wait_for_graph(G),
    reached_from(TID, G, Others).

% holds_up(TID, Others): Others are the threads
% that wait for TID, directly or through a chain.
holds_up(TID, Others) :-
    wait_for_graph(G),
    transpose_ugraph(G, T),
    reached_from(TID, T, Others).
```

```{.prolog .query}
?- waits_on(101, Ts).
Ts = [103, 104].

?- waits_on(103, Ts).
Ts = [104].

?- waits_on(102, Ts).
Ts = [].

?- holds_up(103, Ts).
Ts = [101, 104].

?- holds_up(104, Ts).
Ts = [101, 103].
```

```{.prolog .program}
% deadlocked(TID): TID waits, through a chain of
% owners, for a critical section it owns itself.
deadlocked(TID) :-
    wait_for_graph(G),
    transitive_closure(G, Closure),
    member(TID-Reached, Closure),
    memberchk(TID, Reached).

% deadlock_present: the wait-for graph has a
% cycle.
deadlock_present :-
    wait_for_graph(G),
    \+ top_sort(G, _).
```

```{.prolog .query}
?- wait_for_graph(_G), transitive_closure(_G, _C),
   member(T-Reached, _C),
   format("~d reaches ~w~n", [T, Reached]), fail.
101 reaches [103,104]
103 reaches [103,104]
104 reaches [103,104]
false.

?- deadlocked(T).
T = 103 ;
T = 104.

?- deadlocked(101).
false.

?- deadlock_present.
true.
```

```{.prolog .program}
% cpu_rows(Rows): Rows is the list of Ms-TID pairs
% of the dump, largest CPU time first.
cpu_rows(Rows) :-
    findall(Ms-TID, cpu_time(TID, Ms), Pairs),
    sort(1, @>=, Pairs, Rows).

% add_ms(Row, S0, S): S is S0 plus the CPU time
% of Row.
add_ms(Ms-_, S0, S) :-
    S is S0 + Ms.

% print_cpu_row(Total, Row, Cum0, Cum): print one
% row with its share of Total and the cumulative
% share Cum of the rows so far.
print_cpu_row(Total, Ms-TID, Cum0, Cum) :-
    Cum is Cum0 + Ms,
    Share is 100 * Ms / Total,
    CumShare is 100 * Cum / Total,
    format(
        "~d~t~5|~t~D~7+ ms~t~1f~9+%~t~1f~7+%~n",
        [TID, Ms, Share, CumShare]).

% print_cpu_shares: the CPU table with a
% cumulative share column, largest consumer first.
print_cpu_shares :-
    cpu_rows(Rows),
    foldl(add_ms, Rows, 0, Total),
    foldl(print_cpu_row(Total), Rows, 0, _).
```

```{.prolog .query}
?- print_cpu_shares.
102    9,680 ms  68.5%  68.5%
107    4,100 ms  29.0%  97.5%
100      160 ms   1.1%  98.6%
109       60 ms   0.4%  99.0%
103       40 ms   0.3%  99.3%
104       35 ms   0.2%  99.6%
105       25 ms   0.2%  99.8%
101       20 ms   0.1%  99.9%
106       15 ms   0.1% 100.0%
108        0 ms   0.0% 100.0%
true.
```

# Chapter 20. Synchronization Patterns

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/20-synchronization.md`.

```{.prolog .program}
:- [dump1].

% threshold(Name, Value): the thresholds.
threshold(queue_length, 2).
threshold(contention, 2).
threshold(swarm_size, 4).
threshold(spiking_share, 25).

% system_module(M): M belongs to the operating
% system or a runtime, not to the application.
system_module(ntdll).
system_module(kernelbase).
system_module(kernel32).
system_module(ucrtbase).
system_module(msvcp140).

% pattern(Name, Artifact, Chapter): the patterns
% this chapter recognizes with a predicate.
pattern('Wait Chain (Critical Sections)',
        memory_dump, 20).
pattern('Wait Chain (Mutex Objects)',
    memory_dump, 20).
pattern('Wait Chain (Thread Objects)',
    memory_dump, 20).
pattern('Deadlock (Critical Sections)',
    memory_dump, 20).
pattern('Deadlock (Mixed Objects)',
    memory_dump, 20).
pattern('Blocked Queue', memory_dump, 20).
pattern('High Contention (Critical Sections)',
        memory_dump, 20).
pattern('Critical Section Corruption',
    memory_dump, 20).
pattern('Swarm of Shared Locks', memory_dump, 20).
pattern('Waiting Thread Time', memory_dump, 20).
pattern('Thread Starvation (Normal Priority)',
        memory_dump, 20).
pattern('Blocking Module', memory_dump, 20).
```

```{.prolog .program}
% The two extension relations are dynamic, so that
% the boundary checks of Section 20.5 can add
% facts and take them away again.
:- dynamic mutant/3, waits_for_object/3.

% mutant(Handle, OwnerTID, Name): a mutex object
% with its owner. An extension of the schema.
mutant(0x1a8, 120, 'AppServer.CacheMutex').
mutant(0x1b4, 123, 'AppServer.LogMutex').

% waits_for_object(TID, Kind, Object): as
% waits_for/3, for Kinds mutant and thread. An
% extension of the schema.
waits_for_object(120, thread, 103).
waits_for_object(121, mutant, 0x1a8).
waits_for_object(122, thread, 121).
waits_for_object(123, thread, 124).
waits_for_object(124, mutant, 0x1b4).

% wait_fact(TID, Kind, Object, Fact): Fact is the
% fact, of the shared file or of the extension,
% that records that TID waits for Object of Kind.
wait_fact(T, K, O, waits_for(T, K, O)) :-
    waits_for(T, K, O).
wait_fact(T, K, O, waits_for_object(T, K, O)) :-
    waits_for_object(T, K, O).

% waits(TID, Kind, Object): TID waits for Object
% of Kind, by the shared facts or the extension.
waits(TID, Kind, Object) :-
    wait_fact(TID, Kind, Object, _).
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.

?- aggregate_all(count, waits(_, _, _), N).
N = 8.

?- aggregate_all(set(K), waits(_, K, _), Kinds).
Kinds = [critical_section, mutant, thread].
```

## 20.1 Wait Chain (Critical Sections)

```{.prolog .program}
% wait_edge(Kind, Waiter, Owner, Facts): Waiter
% waits for an object of Kind that Owner holds;
% Facts are the wait fact and the ownership fact
% that say so.
wait_edge(critical_section, W, O,
          [Wait, critical_section(A, O, L, R)]) :-
    wait_fact(W, critical_section, A, Wait),
    critical_section(A, O, L, R),
    O =\= 0.
wait_edge(mutant, W, O,
          [Wait, mutant(H, O, N)]) :-
    wait_fact(W, mutant, H, Wait),
    mutant(H, O, N),
    O =\= 0.
wait_edge(thread, W, O, [Wait]) :-
    wait_fact(W, thread, O, Wait).

% wait_edge(Kind, Waiter, Owner): the edge without
% its facts.
wait_edge(Kind, W, O) :-
    wait_edge(Kind, W, O, _).

% edge_of(+Kind, ?W, ?O, -Edge): a wait edge of
% Kind, or of any kind when Kind is the atom any;
% Edge is K-Facts, the kind of the edge and the
% facts that make it.
edge_of(Kind, W, O, K-Facts) :-
    must_be(oneof([critical_section, mutant,
                   thread, any]), Kind),
    (   Kind == any
    ->  wait_edge(K, W, O, Facts)
    ;   K = Kind,
        wait_edge(K, W, O, Facts)
    ).

% edge_of(+Kind, ?W, ?O): the edge without its
% kind and facts.
edge_of(Kind, W, O) :-
    edge_of(Kind, W, O, _).

% wait_chain(+Kind, -Chain): Chain is the path of
% Kind edges from a waiting thread, followed until
% the next thread would repeat one in the chain.
wait_chain(Kind, [T | Rest]) :-
    edge_of(Kind, T, _),
    follow(Kind, T, [T], Rest).

follow(Kind, T, Visited, Chain) :-
    (   edge_of(Kind, T, Next),
        \+ memberchk(Next, Visited)
    ->  Chain = [Next | Rest],
        follow(Kind, Next, [Next | Visited], Rest)
    ;   Chain = []
    ).

% print_chain(Chain): the threads of Chain joined
% by arrows.
print_chain(Chain) :-
    atomic_list_concat(Chain, ' -> ', Text),
    format("~a~n", [Text]).
```

```{.prolog .query}
?- wait_edge(critical_section, W, O).
W = 101,
O = 103 ;
W = 103,
O = 104 ;
W = 104,
O = 103 ;
false.

?- wait_edge(critical_section, 103, O, _Facts),
   forall(member(F, _Facts), ( print(F), nl )).
waits_for(103,critical_section,140695026508096)
critical_section(140695026508096,104,1,1)
O = 104 ;
false.

?- wait_chain(critical_section, C),
   print_chain(C), fail.
101 -> 103 -> 104
103 -> 104
104 -> 103
false.

?- catch(wait_chain(mutex, _),
   error(type_error(_, Kind), _), true).
Kind = mutex.
```

## 20.2 Wait Chain (Mutex Objects)

```{.prolog .query}
?- wait_chain(mutant, C), print_chain(C), fail.
121 -> 120
124 -> 123
false.

?- wait_chain(mutant, C), last(C, Owner),
   mutant(H, Owner, Name), format("~16r~n", [H]).
1a8
C = [121, 120],
Owner = 120,
H = 424,
Name = 'AppServer.CacheMutex' ;
1b4
C = [124, 123],
Owner = 123,
H = 436,
Name = 'AppServer.LogMutex'.
```

```{.prolog .query}
?- wait_chain(any, [121 | Rest]),
   print_chain([121 | Rest]).
121 -> 120 -> 103 -> 104
Rest = [120, 103, 104] ;
false.
```

## 20.3 Wait Chain (Thread Objects)

```{.prolog .query}
?- wait_chain(thread, C), print_chain(C), fail.
120 -> 103
122 -> 121
123 -> 124
false.

?- wait_chain(any, [122 | Rest]),
   print_chain([122 | Rest]).
122 -> 121 -> 120 -> 103 -> 104
Rest = [121, 120, 103, 104] ;
false.
```

## 20.4 Deadlock (Critical Sections)

```{.prolog .program}
% deadlock_witness(+Kind, -Cycle, -Edges): Cycle
% is a list of threads each waiting, through an
% object of Kind, for the next, and the last for
% the first, the first the smallest; Edges holds,
% in the same order, the edge each thread was
% followed along: its kind and the facts that make
% it, as edge_of/4 selected them.
deadlock_witness(Kind, [T | Path],
                 [Edge | Edges]) :-
    edge_of(Kind, T, Next, Edge),
    cycle_from(Kind, T, Next, [T], Path, Edges),
    min_list([T | Path], T).

% cycle_from(Kind, Start, Current, Visited, Path,
% Edges): Path leads from Current back to Start
% along Kind edges without repeating a thread, and
% Edges are the edges followed.
cycle_from(Kind, Start, Current, Visited,
           Path, Edges) :-
    (   Current == Start
    ->  Path = [],
        Edges = []
    ;   \+ memberchk(Current, Visited),
        Path = [Current | Rest],
        Edges = [Edge | Rest1],
        edge_of(Kind, Current, Next, Edge),
        cycle_from(Kind, Start, Next,
                   [Current | Visited],
                   Rest, Rest1)
    ).

% deadlock(+Kind, -Cycle): Cycle is a cycle of
% Kind edges, from its smallest thread; the
% witness is dropped.
deadlock(Kind, Cycle) :-
    deadlock_witness(Kind, Cycle, _).
```

```{.prolog .query}
?- deadlock(critical_section, Cycle).
Cycle = [103, 104] ;
false.

?- deadlock(mutant, Cycle).
false.

?- deadlock(critical_section, C),
   forall(member(T, C), waits_for(T, _, _)).
C = [103, 104] ;
false.

?- deadlock_witness(critical_section, C, _Edges),
   pairs_keys(_Edges, Kinds),
   pairs_values(_Edges, _Lists),
   maplist(length, _Lists, Lengths).
C = [103, 104],
Kinds = [critical_section, critical_section],
Lengths = [2, 2] ;
false.
```

```{.prolog .program}
:- table reaches/3.

% reaches(+Kind, ?A, ?B): a path of Kind edges
% leads from thread A to thread B.
reaches(Kind, A, B) :-
    edge_of(Kind, A, B).
reaches(Kind, A, B) :-
    reaches(Kind, A, C),
    edge_of(Kind, C, B).

% in_deadlock(+Kind, ?TID): TID lies on a cycle of
% Kind edges.
in_deadlock(Kind, TID) :-
    reaches(Kind, TID, TID).
```

```{.prolog .query}
?- in_deadlock(critical_section, 103).
true.

?- in_deadlock(critical_section, 101).
false.

?- aggregate_all(set(T),
   in_deadlock(critical_section, T), Ts).
Ts = [103, 104].

?- aggregate_all(set(T),
   reaches(critical_section, 101, T), Ts).
Ts = [103, 104].

?- aggregate_all(set(T), reaches(any, 122, T),
   Ts).
Ts = [103, 104, 120, 121].
```

```{.prolog .program}
% cycle_kinds(Edges, Kinds): Kinds is the set of
% kinds of the edges Edges of a witness.
cycle_kinds(Edges, Kinds) :-
    pairs_keys(Edges, Kinds0),
    sort(Kinds0, Kinds).

% deadlock_name(Kinds, Name): the catalog name of
% a deadlock whose selected edges have the set of
% kinds Kinds: the critical section variant, the
% mixed variant for two kinds or more, and the
% family name for one kind of another object.
deadlock_name([critical_section],
              'Deadlock (Critical Sections)').
deadlock_name([Kind], 'Deadlock') :-
    Kind \== critical_section.
deadlock_name([_, _ | _],
              'Deadlock (Mixed Objects)').

% deadlock(+Kind, -Cycle, -Evidence): as the test
% above; the evidence holds the facts of the edges
% the walk selected, the wait fact and the
% ownership fact of each, and the pattern is named
% from the kinds of those edges. Under a variant
% name the instance is the cycle; under the family
% name it is cycle(Kind, Cycle), so that the kind
% of object is reported.
deadlock(Kind, Cycle, Evidence) :-
    deadlock_witness(Kind, Cycle, Edges),
    cycle_kinds(Edges, Kinds),
    deadlock_name(Kinds, Name),
    (   Kinds = [One],
        One \== critical_section
    ->  Instance = cycle(One, Cycle)
    ;   Instance = Cycle
    ),
    pairs_values(Edges, Lists),
    append(Lists, Facts),
    Evidence = evidence(Name, Instance, Facts).
```

```{.prolog .query}
?- deadlock(critical_section, C,
   evidence(Name, _, _Fs)),
   forall(member(F, _Fs), ( print(F), nl )).
waits_for(103,critical_section,140695026508096)
critical_section(140695026508096,104,1,1)
waits_for(104,critical_section,140695026507968)
critical_section(140695026507968,103,2,1)
C = [103, 104],
Name = 'Deadlock (Critical Sections)' ;
false.

?- deadlock(any, C, evidence(Name, _, _)).
C = [103, 104],
Name = 'Deadlock (Critical Sections)' ;
C = [123, 124],
Name = 'Deadlock (Mixed Objects)' ;
false.

?- deadlock(any, [123, 124], evidence(_, _, _Fs)),
   forall(member(F, _Fs), ( print(F), nl )).
waits_for_object(123,thread,124)
waits_for_object(124,mutant,436)
mutant(436,123,'AppServer.LogMutex')
true ;
false.
```

```{.prolog .program}
% fact_edge(Facts, W, O): the list Facts alone
% says that W waits for an object that O holds.
fact_edge(Facts, W, O) :-
    member(waits_for(W, critical_section, A),
           Facts),
    member(critical_section(A, O, _, _), Facts).
fact_edge(Facts, W, O) :-
    member(waits_for_object(W, mutant, H), Facts),
    member(mutant(H, O, _), Facts).
fact_edge(Facts, W, O) :-
    member(waits_for_object(W, thread, O), Facts).

% cycle_entailed(Facts, Cycle): Facts alone entail
% that each thread of Cycle waits for an object
% the next holds, and the last for the first.
cycle_entailed(Facts, Cycle) :-
    Cycle = [First | _],
    append(Cycle, [First], Closed),
    forall(nextto(W, O, Closed),
           fact_edge(Facts, W, O)).
```

```{.prolog .query}
?- forall(deadlock(any, _, evidence(_, C, _Fs)),
          ( ground(_Fs),
            maplist(call, _Fs),
            cycle_entailed(_Fs, C) )).
true.

?- _Fs = [ waits_for(101, critical_section,
                     0x7ff6_1d13_a0c0),
           critical_section(0x7ff6_1d13_a0c0,
                            103, 2, 1),
           waits_for(103, critical_section,
                     0x7ff6_1d13_a140),
           critical_section(0x7ff6_1d13_a140,
                            104, 1, 1) ],
   maplist(call, _Fs).
true.

?- _Fs = [ waits_for(101, critical_section,
                     0x7ff6_1d13_a0c0),
           critical_section(0x7ff6_1d13_a0c0,
                            103, 2, 1),
           waits_for(103, critical_section,
                     0x7ff6_1d13_a140),
           critical_section(0x7ff6_1d13_a140,
                            104, 1, 1) ],
   cycle_entailed(_Fs, [103, 104]).
false.
```

## 20.5 Deadlock (Mixed Objects)

```{.prolog .program}
% deadlock_mixed(-Cycle, -Kinds): Cycle is a cycle
% whose selected edges have more than one kind,
% listed in Kinds.
deadlock_mixed(Cycle, Kinds) :-
    deadlock_witness(any, Cycle, Edges),
    cycle_kinds(Edges, Kinds),
    Kinds = [_, _ | _].
```

```{.prolog .query}
?- deadlock_witness(any, Cycle, _Edges),
   cycle_kinds(_Edges, Kinds).
Cycle = [103, 104],
Kinds = [critical_section] ;
Cycle = [123, 124],
Kinds = [mutant, thread] ;
false.

?- deadlock_mixed(Cycle, Kinds).
Cycle = [123, 124],
Kinds = [mutant, thread] ;
false.
```

### 20.5.1 Two Boundary Cases

```{.prolog .query}
?- assertz(waits_for_object(103, mutant, 1)),
   assertz(mutant(1, 104, a)).
true.

?- deadlock(critical_section, C,
   evidence(Name, I, _Fs)),
   forall(member(F, _Fs), ( print(F), nl )).
waits_for(103,critical_section,140695026508096)
critical_section(140695026508096,104,1,1)
waits_for(104,critical_section,140695026507968)
critical_section(140695026507968,103,2,1)
C = I, I = [103, 104],
Name = 'Deadlock (Critical Sections)' ;
false.

?- deadlock(critical_section, _,
            evidence(_, _, _Fs)),
   member(F, _Fs), F \= waits_for(_, _, _),
   F \= critical_section(_, _, _, _).
false.

?- deadlock(any, [103, 104],
            evidence(Name, _, _Fs)),
   length(_Fs, N), _Fs = [_First | _],
   functor(_First, Relation, _).
Name = 'Deadlock (Critical Sections)',
N = 4,
Relation = waits_for ;
Name = 'Deadlock (Mixed Objects)',
N = 4,
Relation = waits_for_object ;
false.

?- retractall(waits_for_object(103, mutant, 1)),
   retractall(mutant(1, 104, a)).
true.
```

```{.prolog .query}
?- assertz(waits_for_object(201, mutant, 1)),
   assertz(waits_for_object(202, mutant, 2)),
   assertz(mutant(1, 202, a)),
   assertz(mutant(2, 201, b)).
true.

?- deadlock(mutant, C, evidence(Name, I, _Fs)),
   forall(member(F, _Fs), ( print(F), nl )).
waits_for_object(201,mutant,1)
mutant(1,202,a)
waits_for_object(202,mutant,2)
mutant(2,201,b)
C = [201, 202],
Name = 'Deadlock',
I = cycle(mutant, [201, 202]) ;
false.

?- deadlock_mixed(C, Kinds).
C = [123, 124],
Kinds = [mutant, thread] ;
false.

?- deadlock(any, C, evidence(Name, _, _)).
C = [103, 104],
Name = 'Deadlock (Critical Sections)' ;
C = [201, 202],
Name = 'Deadlock' ;
C = [123, 124],
Name = 'Deadlock (Mixed Objects)' ;
false.

?- retractall(waits_for_object(201, mutant, _)),
   retractall(waits_for_object(202, mutant, _)),
   retractall(mutant(1, 202, a)),
   retractall(mutant(2, 201, b)),
   aggregate_all(count, waits(_, _, _), N).
N = 8.
```

## 20.6 Blocked Queue

```{.prolog .program}
% blocked_queue(?Kind, ?Object, -Waiters): at
% least the threshold many threads wait for Object
% of Kind; Waiters lists them.
blocked_queue(Kind, Object, Waiters) :-
    bagof(W, waits(W, Kind, Object), Waiters),
    length(Waiters, N),
    threshold(queue_length, Min),
    N >= Min.
```

```{.prolog .query}
?- blocked_queue(K, A, Ws), format("~16r~n", [A]).
7ff61d13a0c0
K = critical_section,
A = 140695026507968,
Ws = [101, 104] ;
false.

?- blocked_queue(_, A, _),
   critical_section(A, O, _, _), waits(O, _, _).
A = 140695026507968,
O = 103 ;
false.
```

## 20.7 High Contention (Critical Sections)

```{.prolog .program}
% high_contention(?Addr, -WaiterCount): the
% critical section at Addr reports at least the
% threshold many waiting threads.
high_contention(Addr, WaiterCount) :-
    critical_section(Addr, _, WaiterCount, _),
    threshold(contention, Min),
    WaiterCount >= Min.
```

```{.prolog .query}
?- high_contention(A, N), format("~16r~n", [A]).
7ff61d13a0c0
A = 140695026507968,
N = 2 ;
false.

?- forall(critical_section(A, _, L, _),
          ( aggregate_all(count,
                waits_for(_, critical_section, A),
                W),
            format("~16r ~d ~d~n", [A, L, W]),
            L =:= W )).
7ff61d13a0c0 2 2
7ff61d13a140 1 1
7ff61d13a1c0 0 0
true.
```

## 20.8 Critical Section Corruption

```{.prolog .program}
% critical_section_corruption(?Addr, -Reason): the
% critical section at Addr is in an impossible
% state for Reason.
critical_section_corruption(Addr, Reason) :-
    critical_section(Addr, Owner, Waiters, Rec),
    inconsistent(Addr, Owner, Waiters, Rec,
                 Reason).

% inconsistent(Addr, Owner, Waiters, Rec, Reason):
% the fields of a critical section violate the
% rule named by Reason.
inconsistent(_, 0, _, Rec, Reason) :-
    Rec > 0,
    Reason = recursion_without_owner.
inconsistent(_, 0, Waiters, _, Reason) :-
    Waiters > 0,
    Reason = waiters_without_owner.
inconsistent(_, Owner, _, 0, Reason) :-
    Owner =\= 0,
    Reason = owner_without_recursion.
inconsistent(_, Owner, _, _, Reason) :-
    Owner =\= 0,
    \+ thread(Owner, _),
    Reason = owner_not_a_thread(Owner).
inconsistent(Addr, _, Waiters, _, Reason) :-
    aggregate_all(count,
        waits(_, critical_section, Addr), N),
    N =\= Waiters,
    Reason = waiter_count_mismatch(Waiters, N).
```

```{.prolog .query}
?- critical_section_corruption(A, R).
false.

?- inconsistent(0x7ff6_1d13_a200, 0, 3, 0, R).
R = waiters_without_owner ;
R = waiter_count_mismatch(3, 0).

?- inconsistent(0x7ff6_1d13_a200, 777, 1, 1, R).
R = owner_not_a_thread(777) ;
R = waiter_count_mismatch(1, 0).
```

## 20.9 Swarm of Shared Locks

```{.prolog .program}
% shared_lock_wait(TID, Addr): TID waits on the
% reader-writer lock at Addr. An extension of the
% schema.
shared_lock_wait(125, 0x7ff6_1d13_b000).
shared_lock_wait(126, 0x7ff6_1d13_b000).
shared_lock_wait(127, 0x7ff6_1d13_b000).
shared_lock_wait(128, 0x7ff6_1d13_b000).
shared_lock_wait(129, 0x7ff6_1d13_b000).
shared_lock_wait(130, 0x7ff6_1d13_b040).

% swarm_of_shared_locks(?Addr, -TIDs): at least
% the threshold many threads wait on the lock at
% Addr.
swarm_of_shared_locks(Addr, TIDs) :-
    bagof(T, shared_lock_wait(T, Addr), TIDs),
    length(TIDs, N),
    threshold(swarm_size, Min),
    N >= Min.
```

```{.prolog .query}
?- swarm_of_shared_locks(A, Ts),
   format("~16r~n", [A]).
7ff61d13b000
A = 140695026511872,
Ts = [125, 126, 127, 128, 129] ;
false.
```

## 20.10 Dispatch Level Spin

## 20.11 Waiting Thread Time

```{.prolog .program}
% wait_time(TID, Ms): TID has been waiting for Ms
% milliseconds. An extension of the schema.
wait_time(100, 20).
wait_time(101, 9800).
wait_time(103, 12400).
wait_time(104, 12380).
wait_time(105, 61000).
wait_time(106, 59500).
wait_time(108, 4900).

% waiting_thread_time(-TID, -Ms): the waiting
% threads with their wait times, longest first.
waiting_thread_time(TID, Ms) :-
    order_by([desc(Ms)], wait_time(TID, Ms)).
```

```{.prolog .query}
?- forall(waiting_thread_time(T, Ms),
          format("~d~t~6|~t~D~8+ ms~n", [T, Ms])).
105     61,000 ms
106     59,500 ms
103     12,400 ms
104     12,380 ms
101      9,800 ms
108      4,900 ms
100         20 ms
true.

?- waiting_thread_time(T, _), waits(T, _, _).
T = 103 ;
T = 104 ;
T = 101 ;
false.
```

## 20.12 Thread Starvation (Normal Priority)

```{.prolog .program}
% priority(TID, Level): the scheduling priority of
% TID. An extension of the schema.
priority(102, above_normal).
priority(107, above_normal).
priority(100, normal).
priority(101, normal).
priority(103, normal).
priority(104, normal).
priority(105, normal).
priority(106, normal).
priority(108, normal).
priority(109, normal).

% higher_priority(P, Q): level P is above level Q.
higher_priority(above_normal, normal).
higher_priority(high, normal).
higher_priority(high, above_normal).

% cpu_share(TID, Share): the CPU time of TID as a
% percentage of the total, as in Chapter 18.
cpu_share(TID, Share) :-
    thread_time(TID, U, K),
    Ms is U + K,
    aggregate_all(sum(U1 + K1),
                  thread_time(_, U1, K1), Total),
    Total > 0,
    Share is 100.0 * Ms / Total.

% spiking_thread(TID): as in Chapter 18.
spiking_thread(TID) :-
    cpu_share(TID, Share),
    threshold(spiking_share, Min),
    Share >= Min.

% thread_starvation(-TID, -By): TID is a normal
% priority thread not blocked on a recorded object
% and not a pool thread, while By spikes at a
% higher priority.
thread_starvation(TID, By) :-
    priority(TID, normal),
    thread_state(TID, waiting(user_request)),
    \+ waits(TID, _, _),
    \+ frame(TID, _, ntdll, 'TppWorkerThread', _),
    spiking_thread(By),
    priority(By, P),
    higher_priority(P, normal).
```

```{.prolog .query}
?- thread_starvation(T, By).
T = 100,
By = 102 ;
T = 100,
By = 107 ;
false.
```

## 20.13 Blocking Module

```{.prolog .program}
% blocking_module(?Addr, -Owner, -Module): Owner
% holds the critical section at Addr and is
% executing in Module, its topmost frame outside
% the system modules.
blocking_module(Addr, Owner, Module) :-
    critical_section(Addr, Owner, _, _),
    Owner =\= 0,
    aggregate_all(min(N),
                  ( frame(Owner, N, M, _, _),
                    \+ system_module(M)
                  ),
                  Top),
    frame(Owner, Top, Module, _, _).
```

```{.prolog .query}
?- blocking_module(A, O, M),
   format("~16r~n", [A]).
7ff61d13a0c0
A = 140695026507968,
O = 103,
M = dbclient ;
7ff61d13a140
A = 140695026508096,
O = 104,
M = appserver ;
false.

?- blocking_module(_, O, M), frame(O, N, M, F, _),
   \+ ( frame(O, N1, M, _, _), N1 < N ).
O = 103,
M = dbclient,
N = 4,
F = 'Connection::Send' ;
O = 104,
M = appserver,
N = 4,
F = 'Session::Lookup' ;
false.
```

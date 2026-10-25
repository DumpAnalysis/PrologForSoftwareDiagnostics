# Chapter 11. The Dynamic Database, Global State, and Tabling

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/11-dynamic-db-and-tabling.md`.

## 11.1 Static and Dynamic Predicates

```{.prolog .program}
:- [dump1].

% marked(TID): the analyst has marked TID for
% attention.
:- dynamic marked/1.
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.

?- marked(T).
false.

?- catch(assertz(thread(110, 4120)),
         error(permission_error(Op, Kind, P), _),
         true).
Op = modify,
Kind = static_procedure,
P = thread/2.
```

## 11.2 Adding and Removing Clauses

```{.prolog .query}
?- assertz(marked(102)), assertz(marked(107)),
   asserta(marked(109)).
true.

?- marked(T).
T = 109 ;
T = 102 ;
T = 107.

?- assertz((hot(T) :- marked(T),
                      thread_state(T, running))).
true.
```

```{.prolog .query}
?- hot(T).
T = 102 ;
T = 107.
```

```{.prolog .query}
?- retract(marked(109)).
true.

?- retract(marked(999)).
false.

?- retract((hot(T) :- Body)).
Body = (marked(T), thread_state(T, running)).

?- retract(marked(T)).
T = 102 ;
T = 107.

?- marked(T).
false.

?- assertz(marked(102)), retractall(marked(_)),
   marked(T).
false.
```

## 11.3 The Logical Update View

```{.prolog .program}
% item(N): a small dynamic relation for the
% examples of this section.
:- dynamic item/1.
item(1).
item(2).
```

```{.prolog .query}
?- item(X), Y is X + 10, assertz(item(Y)), fail.
false.

?- item(X).
X = 1 ;
X = 2 ;
X = 11 ;
X = 12.

?- item(X), retract(item(X)), fail.
false.

?- item(X).
false.
```

## 11.4 Inspecting the Program

```{.prolog .query}
?- clause(frame(109, 0, M, F, O), Body).
M = dbclient,
F = 'Buffer::Copy',
O = 26,
Body = true.

?- clause(thread_state(T, running), true).
T = 102 ;
T = 107.
```

```{.prolog .query}
?- predicate_property(marked(_), dynamic).
true.

?- predicate_property(frame(_, _, _, _, _),
   dynamic).
false.

?- predicate_property(frame(_, _, _, _, _),
   number_of_clauses(N)).
N = 78.

?- predicate_property(marked(_),
   number_of_clauses(N)).
N = 0.

?- current_predicate(frame/A).
A = 5 ;
false.

?- current_predicate(marked/1).
true.

?- current_predicate(hot/1).
true.

?- predicate_property(hot(_),
   number_of_clauses(N)).
N = 0.
```

```{.prolog .query}
?- listing(item/1).
:- dynamic item/1.

true.

?- assertz(item(5)), listing(item/1).
:- dynamic item/1.

item(5).

true.
```

## 11.5 Global Variables

```{.prolog .query}
?- b_setval(v, 1),
   ( b_setval(v, 2), fail ; true ),
   b_getval(v, X).
X = 1.

?- nb_setval(w, 1),
   ( nb_setval(w, 2), fail ; true ),
   nb_getval(w, X).
X = 2.

?- nb_getval(w, X).
X = 2.

?- catch(nb_getval(unset, X), error(E, _), true).
E = existence_error(variable, unset).

?- nb_setval(t, f(X)), X = 1, nb_getval(t, T).
X = 1,
T = f(_).

?- b_setval(t, f(X)), X = 1, b_getval(t, T).
X = 1,
T = f(1).
```

```{.prolog .query}
?- flag(hits, _, 0),
   (   thread(T, _),
       thread_state(T, waiting(_)),
       flag(hits, N, N + 1),
       fail
   ;   flag(hits, Hits, Hits)
   ).
Hits = 7.

?- flag(next_id, Id, Id + 1).
Id = 0.

?- flag(next_id, Id, Id + 1).
Id = 1.
```

## 11.6 Tabling

```{.prolog .program}
% edge(X, Y): a small directed graph with a cycle
% a, b, c, a and a tail to d.
edge(a, b).
edge(b, c).
edge(c, a).
edge(c, d).

% reaches(X, Y): Y is reachable from X by one or
% more edges.  The definition of Chapter 4.
:- table reaches/2.
reaches(X, Y) :-
    edge(X, Y).
reaches(X, Y) :-
    edge(X, Z),
    reaches(Z, Y).
```

```{.prolog .query}
?- setof(Y, reaches(a, Y), Ys).
Ys = [a, b, c, d].

?- setof(X, reaches(X, a), Xs).
Xs = [a, b, c].

?- reaches(d, Y).
false.

?- reaches(a, a).
true.
```

```{.prolog .program}
% path(X, Y): as reaches/2, written with the
% recursive goal first.
:- table path/2.
path(X, Y) :-
    path(X, Z),
    edge(Z, Y).
path(X, Y) :-
    edge(X, Y).
```

```{.prolog .query}
?- setof(Y, path(a, Y), Ys).
Ys = [a, b, c, d].
```

```{.prolog .query}
?- listing(path/2).
:- table path/2 as variant.

path(X, Y) :-
    path(X, Z),
    edge(Z, Y).
path(X, Y) :-
    edge(X, Y).

true.

?- predicate_property(path(_, _), tabled).
true.
```

```{.prolog .program}
% dist(X, Y, D): D is the length of the shortest
% path from X to Y.
:- table dist(_, _, min).
dist(X, Y, 1) :-
    edge(X, Y).
dist(X, Y, D) :-
    dist(X, Z, D0),
    edge(Z, Y),
    D is D0 + 1.
```

```{.prolog .query}
?- setof(Y-D, dist(a, Y, D), Ds).
Ds = [a-3, b-1, c-2, d-3].

?- dist(a, a, D).
D = 3.
```

```{.prolog .program}
% shorter(P1, P2, P): P is the shorter of the two
% lists P1 and P2, P1 when they are equally long.
shorter(P1, P2, P) :-
    length(P1, L1),
    length(P2, L2),
    (   L1 =< L2
    ->  P = P1
    ;   P = P2
    ).

% route(X, Y, Path): Path is a shortest list of
% vertices from X to Y along edges.
:- table route(_, _, lattice(shorter/3)).
route(X, Y, [X, Y]) :-
    edge(X, Y).
route(X, Y, Path) :-
    route(X, Z, Path0),
    edge(Z, Y),
    append(Path0, [Y], Path).
```

```{.prolog .query}
?- route(a, d, Path).
Path = [a, b, c, d].

?- route(a, a, Path).
Path = [a, b, c, a].

?- route(c, c, Path).
Path = [c, a, b, c].
```

```{.prolog .program}
% fib(N, F): F is the Nth Fibonacci number.
fib(N, F) :-
    (   N < 2
    ->  F = N
    ;   N1 is N - 1,
        N2 is N - 2,
        fib(N1, F1),
        fib(N2, F2),
        F is F1 + F2
    ).

% tfib(N, F): as fib/2, tabled.
:- table tfib/2.
tfib(N, F) :-
    (   N < 2
    ->  F = N
    ;   N1 is N - 1,
        N2 is N - 2,
        tfib(N1, F1),
        tfib(N2, F2),
        F is F1 + F2
    ).
```

```{.prolog .query}
?- time(fib(25, F)).
% 728,355 inferences, <...> CPU in <...>
F = 75025.

?- time(tfib(25, F)).
% <...> inferences, <...> CPU in <...>
F = 75025.

?- time(tfib(25, F)).
% <...> inferences, <...> CPU in <...>
F = 75025.

?- tfib(200, F).
F = 280571172992510140037611932413038677189525.
```

## 11.7 Diagnostic Use

```{.prolog .program}
% blocked_by(Waiter, Owner): Waiter waits for a
% critical section that Owner owns.
blocked_by(Waiter, Owner) :-
    waits_for(Waiter, critical_section, Addr),
    critical_section(Addr, Owner, _, _),
    Owner \== 0.

% blocked_through(TID, Other): TID is blocked by
% Other directly or through a chain of owners.
% The definition of Chapter 4, tabled.
:- table blocked_through/2.
blocked_through(TID, Other) :-
    blocked_by(TID, Other).
blocked_through(TID, Other) :-
    blocked_by(TID, Owner),
    blocked_through(Owner, Other).
```

```{.prolog .query}
?- setof(X, blocked_through(101, X), Xs).
Xs = [103, 104].

?- setof(X, blocked_through(103, X), Xs).
Xs = [103, 104].

?- blocked_through(102, X).
false.

?- setof(T, blocked_through(T, T), Ts).
Ts = [103, 104].
```

```{.prolog .program}
% wait_chain(From, To, Chain): Chain is a shortest
% list of threads from From to To in which each
% thread is blocked by the next.
:- table wait_chain(_, _, lattice(shorter/3)).
wait_chain(From, To, [From, To]) :-
    blocked_by(From, To).
wait_chain(From, To, Chain) :-
    wait_chain(From, Mid, Chain0),
    blocked_by(Mid, To),
    append(Chain0, [To], Chain).

% deadlock_cycle(Cycle): Cycle is a wait chain
% from a thread back to itself.
deadlock_cycle(Cycle) :-
    wait_chain(TID, TID, Cycle).
```

```{.prolog .query}
?- setof(To-Chain, wait_chain(101, To, Chain),
   Chains).
Chains = [103-[101, 103], 104-[101, 103, 104]].

?- setof(Cycle, deadlock_cycle(Cycle), Cycles).
Cycles = [[103, 104, 103], [104, 103, 104]].
```

```{.prolog .program}
% print_chain(Chain): one line per step of the
% chain, with the critical section waited for.
print_chain(Chain) :-
    forall(nextto(Waiter, Owner, Chain),
           print_step(Waiter, Owner)).

% print_step(Waiter, Owner): one line of a chain.
print_step(Waiter, Owner) :-
    waits_for(Waiter, critical_section, Addr),
    format("~d waits for ~16r, owner ~d~n",
           [Waiter, Addr, Owner]).
```

```{.prolog .query}
?- wait_chain(101, 104, _Chain),
   print_chain(_Chain).
101 waits for 7ff61d13a0c0, owner 103
103 waits for 7ff61d13a140, owner 104
true.

?- once(( deadlock_cycle(_Cycle),
          _Cycle = [103 | _] )),
   print_chain(_Cycle).
103 waits for 7ff61d13a140, owner 104
104 waits for 7ff61d13a0c0, owner 103
true.
```

```{.prolog .program}
% annotation(Id, Subject, Note): the analyst's
% note number Id about Subject, a term such as
% thread(TID) or module(Name).
:- dynamic annotation/3.

% annotate(Subject, Note): record Note about
% Subject under the next free identifier.
annotate(Subject, Note) :-
    flag(annotation_id, Id0, Id0 + 1),
    Id is Id0 + 1,
    assertz(annotation(Id, Subject, Note)).

% withdraw(Id): remove annotation Id.
withdraw(Id) :-
    retract(annotation(Id, _, _)).
```

```{.prolog .query}
?- annotate(thread(103), "owns A, waits for B").
true.

?- annotate(thread(104), "owns B, waits for A").
true.

?- annotate(module(cachelib), "CacheWorks").
true.

?- annotate(thread(101), "held up by deadlock").
true.

?- listing(annotation/3).
:- dynamic annotation/3.

annotation(1, thread(103), "owns A, waits for B").
annotation(2, thread(104), "owns B, waits for A").
annotation(3, module(cachelib), "CacheWorks").
annotation(4, thread(101), "held up by deadlock").

true.
```

```{.prolog .query}
?- annotation(_, thread(T), Note),
   thread_state(T, State),
   format("~d ~w: ~s~n", [T, State, Note]), fail.
103 waiting(user_request): owns A, waits for B
104 waiting(user_request): owns B, waits for A
101 waiting(user_request): held up by deadlock
false.

?- deadlock_cycle(_Cycle), member(T, _Cycle),
   \+ annotation(_, thread(T), _).
false.

?- withdraw(3).
true.

?- annotation(Id, module(M), _).
false.

?- annotate(module(cachelib), "no symbols"),
   annotation(Id, module(M), Note).
Id = 5,
M = cachelib,
Note = "no symbols".
```

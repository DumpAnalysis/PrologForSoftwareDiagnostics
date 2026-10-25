# Chapter 29. Meta-Interpreters and Explanation

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/29-meta-interpreters.md`.

## 29.1 Clauses as Data

```{.prolog .program}
:- [dump1].
:- use_module(patterns_dump, [threshold/2]).

% blocked_thread(?TID): the dump records an object
% TID waits for.
blocked_thread(TID) :-
    waits_for(TID, _, _).

% owner(?Addr, ?TID): TID owns the critical
% section at Addr.
owner(Addr, TID) :-
    critical_section(Addr, TID, _, _),
    TID =\= 0.

% blocks(?Blocker, ?Blocked): Blocked waits for a
% critical section that Blocker owns.
blocks(Blocker, Blocked) :-
    waits_for(Blocked, critical_section, Addr),
    owner(Addr, Blocker).

% deadlock(?T1, ?T2): T1 and T2 block each other.
deadlock(T1, T2) :-
    blocks(T1, T2),
    blocks(T2, T1),
    T1 < T2.

% cpu_time(?TID, -Ms): the CPU time of TID in ms.
cpu_time(TID, Ms) :-
    thread_time(TID, User, Kernel),
    Ms is User + Kernel.

% total_cpu(-Total): the CPU time of all threads.
total_cpu(Total) :-
    aggregate_all(sum(Ms), cpu_time(_, Ms),
                  Total).

% cpu_share(?TID, -Share): the CPU time of TID as
% a percentage of the total.
cpu_share(TID, Share) :-
    cpu_time(TID, Ms),
    total_cpu(Total),
    Total > 0,
    Share is 100.0 * Ms / Total.

% spiking_thread(?TID): the CPU share of TID is at
% least the threshold.
spiking_thread(TID) :-
    cpu_share(TID, Share),
    threshold(spiking_share, Min),
    Share >= Min.

% handle_leak(?Type): the count of handles of Type
% exceeds the limit for one type.
handle_leak(Type) :-
    handle_count(_, Type, Count),
    threshold(handle_type_count, Max),
    Count > Max.
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.

?- clause(deadlock(A, B), Body).
Body = (blocks(A, B), blocks(B, A), A<B).

?- clause(threshold(spiking_share, V), Body).
V = 25,
Body = true.

?- clause(blocks(A, B), _Body),
   portray_clause((blocks(A, B) :- _Body)).
blocks(A, B) :-
    waits_for(B, critical_section, C),
    owner(C, A).
true.

?- clause(waits_for(101, K, Addr), Body).
K = critical_section,
Addr = 140695026507968,
Body = true.
```

```{.prolog .query}
?- current_prolog_flag(protect_static_code, F).
F = false.

?- catch(clause(write(_), _),
         error(permission_error(Op, Type, PI), _),
         true).
Op = access,
Type = private_procedure,
PI = write/1.

?- catch(clause(true, _),
         error(permission_error(Op, Type, PI), _),
         true).
Op = access,
Type = private_procedure,
PI = true/0.

?- clause(no_such_predicate(_), _).
false.

?- clause((a, b), Body).
Body = call((a, b)).
```

```{.prolog .query}
?- predicate_property(A < B, built_in).
true.

?- predicate_property(member(_, _),
                      imported_from(M)).
M = lists.

?- predicate_property(threshold(_, _),
                      imported_from(M)).
M = patterns_dump.

?- module_property(lists, class(C1)),
   module_property(patterns_dump, class(C2)).
C1 = library,
C2 = user.

?- predicate_property(deadlock(_, _), built_in).
false.

?- predicate_property(deadlock(_, _),
                      imported_from(_)).
false.

?- predicate_property(deadlock(_, _),
                      number_of_clauses(N)).
N = 1.
```

## 29.2 The Vanilla Meta-Interpreter

```prolog
naive_solve(true).
naive_solve((A, B)) :-
    naive_solve(A),
    naive_solve(B).
naive_solve(G) :-
    clause(G, Body),
    naive_solve(Body).
```

```{.prolog .program}
% solve(+Goal): Goal is provable from the program,
% by interpretation of its clauses.
solve(true).
solve((A, B)) :-
    solve(A),
    solve(B).
solve((If -> Then ; Else)) :-
    (   solve(If)
    ->  solve(Then)
    ;   solve(Else)
    ).
solve((A ; B)) :-
    A \= (_ -> _),
    (   solve(A)
    ;   solve(B)
    ).
solve(\+ A) :-
    \+ solve(A).
solve(findall(T, G, L)) :-
    findall(T, solve(G), L).
solve(aggregate_all(Spec, G, R)) :-
    aggregate_all(Spec, solve(G), R).
solve(G) :-
    \+ control(G),
    \+ collecting(G),
    (   system_goal(G)
    ->  call(G)
    ;   clause(G, Body),
        solve(Body)
    ).

% control(@Goal): Goal is a control construct that
% solve/1 handles by a clause of its own.
control(true).
control((_, _)).
control((_ ; _)).
control(\+ _).

% collecting(@Goal): Goal collects the solutions
% of an inner goal, which solve/1 interprets.
collecting(findall(_, _, _)).
collecting(aggregate_all(_, _, _)).

% system_goal(+Goal): Goal is executed by the
% system, not interpreted: a built-in or a
% predicate of a library module.
system_goal(G) :-
    predicate_property(G, built_in).
system_goal(G) :-
    predicate_property(G, imported_from(M)),
    module_property(M, class(library)).
```

```{.prolog .query}
?- solve(deadlock(A, B)).
A = 103,
B = 104 ;
false.

?- solve(blocked_thread(T)).
T = 101 ;
T = 103 ;
T = 104 ;
false.

?- solve((deadlock(A, B), \+ spiking_thread(A))).
A = 103,
B = 104 ;
false.

?- solve(spiking_thread(T)).
T = 102 ;
T = 107 ;
false.

?- solve(member(X, [a, b])).
X = a ;
X = b.
```

## 29.3 Proof Trees

```{.prolog .program}
% solve(+Goal, -Proof): Proof is a proof tree of
% Goal.
solve(G, proof(G, Subs)) :-
    \+ control(G),
    (   collecting(G)
    ->  collect(G, Subs)
    ;   system_goal(G)
    ->  call(G),
        Subs = []
    ;   clause(G, Body),
        solve_body(Body, Subs)
    ).

% collect(+Goal, -Subs): Goal is a collecting goal
% whose inner goal has the proofs Subs, one per
% solution; the collected result is computed from
% the solutions as the goal itself computes it.
collect(findall(T, G, L), Subs) :-
    findall(T-P, solve(G, P), Pairs),
    pairs_keys_values(Pairs, L, Subs).
collect(aggregate_all(Spec, G, R), Subs) :-
    findall(Spec-P, solve(G, P), Pairs),
    pairs_keys_values(Pairs, Specs, Subs),
    aggregate_all(Spec, member(Spec, Specs), R).

% solve_body(+Body, -Proofs): Proofs is the list
% of proof trees of the goals of Body.
solve_body(true, []).
solve_body((A, B), Proofs) :-
    solve_body(A, PA),
    solve_body(B, PB),
    append(PA, PB, Proofs).
solve_body((If -> Then ; Else), Proofs) :-
    (   solve_body(If, PI)
    ->  solve_body(Then, PT),
        append(PI, PT, Proofs)
    ;   solve_body(Else, Proofs)
    ).
solve_body((A ; B), Proofs) :-
    A \= (_ -> _),
    (   solve_body(A, Proofs)
    ;   solve_body(B, Proofs)
    ).
solve_body(\+ A, [proof(\+ A, [])]) :-
    \+ solve_body(A, _).
solve_body(G, [Proof]) :-
    \+ control(G),
    solve(G, Proof).
```

```{.prolog .query}
?- solve(deadlock(A, B), proof(G, _Subs)),
   length(_Subs, N).
A = 103,
B = 104,
G = deadlock(103, 104),
N = 3 ;
false.

?- solve(handle_leak(T), proof(_, _Subs)),
   member(proof(G, Subs), _Subs).
T = event,
G = handle_count(4120, event, 12040),
Subs = [] ;
T = event,
G = threshold(handle_type_count, 5000),
Subs = [] ;
T = event,
G = (12040>5000),
Subs = [] ;
false.

?- solve(spiking_thread(107), proof(_, _Subs)),
   forall(member(proof(G, _), _Subs),
          ( print(G), nl )).
cpu_share(107,29.006013441811106)
threshold(spiking_share,25)
29.006013441811106>=25
true ;
false.

?- solve(total_cpu(T),
         proof(_, [proof(aggregate_all(_, _, _),
                         _Inner)])),
   length(_Inner, N).
T = 14135,
N = 10.

?- solve(blocked_thread(108), P).
false.
```

## 29.4 Printing Proofs as Explanations

```{.prolog .program}
% portray(+Term): hook. Integers above 0xffff are
% written in hexadecimal.
portray(X) :-
    integer(X),
    X > 0xffff,
    format("0x~16r", [X]).
```

```{.prolog .query}
?- print(waits_for(101, cs, 0x7ff6_1d13_a0c0)),
   nl.
waits_for(101,cs,0x7ff61d13a0c0)
true.

?- waits_for(101, Kind, Addr).
Kind = critical_section,
Addr = 0x7ff61d13a0c0.

?- format("~p ~w~n",
          [0x7ff6_1d13_a0c0, 0x7ff6_1d13_a0c0]).
0x7ff61d13a0c0 140695026507968
true.
```

```{.prolog .program}
% why(+Goal): print a proof of Goal as an indented
% explanation; one answer per proof.
why(G) :-
    solve(G, Proof),
    print_proof(Proof, 0).

print_proof(proof(G, Subs), Depth) :-
    Indent is Depth * 2,
    \+ \+ ( numbervars(G, 0, _,
                       [singletons(true)]),
            format("~t~*|~p", [Indent, G]) ),
    (   Subs == []
    ->  (   leaf_fact(G)
        ->  nl
        ;   format(" holds~n")
        )
    ;   format(" because~n"),
        Deeper is Depth + 1,
        forall(member(Sub, Subs),
               print_proof(Sub, Deeper))
    ).

% leaf_fact(+Goal): a leaf that is a fact of the
% knowledge base, not a built-in or a negation.
leaf_fact(G) :-
    G \= (\+ _),
    \+ system_goal(G).
```

```{.prolog .query}
?- why(handle_leak(T)).
handle_leak(event) because
  handle_count(4120,event,12040)
  threshold(handle_type_count,5000)
  12040>5000 holds
T = event ;
false.

?- why(deadlock(A, B)).
deadlock(103,104) because
  blocks(103,104) because
    waits_for(104,critical_section,0x7ff61d13a0c0)
    owner(0x7ff61d13a0c0,103) because
      critical_section(0x7ff61d13a0c0,103,2,1)
      103=\=0 holds
  blocks(104,103) because
    waits_for(103,critical_section,0x7ff61d13a140)
    owner(0x7ff61d13a140,104) because
      critical_section(0x7ff61d13a140,104,1,1)
      104=\=0 holds
  103<104 holds
A = 103,
B = 104 ;
false.
```

```{.prolog .query}
?- why((deadlock(A, B), \+ spiking_thread(A))).
false.

?- why(blocked_thread(108)).
false.
```

## 29.5 Evidence from Proofs

```{.prolog .program}
% pattern_name(Functor, Name): the catalog name of
% the pattern the recognizer Functor recognizes.
pattern_name(blocked_thread,
             'Blocked Thread (Software)').
pattern_name(deadlock,
             'Deadlock (Critical Sections)').
pattern_name(spiking_thread, 'Spiking Thread').
pattern_name(handle_leak, 'Handle Leak').

% proof_facts(+Proof, -Facts): the facts of the
% knowledge base among the leaves of Proof.
proof_facts(proof(G, []), Facts) :-
    (   leaf_fact(G)
    ->  Facts = [G]
    ;   Facts = []
    ).
proof_facts(proof(_, [Sub|Subs]), Facts) :-
    maplist(proof_facts, [Sub|Subs], Lists),
    append(Lists, Facts).

% evidence(+Goal, -Evidence): Evidence is
% evidence(Pattern, Instance, Facts) for one proof
% of the recognizer goal Goal: Pattern its catalog
% name, Instance its argument or its two arguments
% as a pair, Facts the facts of the proof, once.
evidence(Goal, Evidence) :-
    Evidence = evidence(Pattern, Instance, Facts),
    solve(Goal, Proof),
    Goal =.. [Functor | Args],
    pattern_name(Functor, Pattern),
    instance_of(Args, Instance),
    proof_facts(Proof, Facts0),
    list_to_set(Facts0, Facts).

instance_of([Instance], Instance).
instance_of([A, B], A-B).

% print_evidence(+Goal): one line per fact.
print_evidence(Goal) :-
    evidence(Goal, evidence(P, I, Facts)),
    format("~a: ~p~n", [P, I]),
    forall(member(F, Facts),
           format("  ~p~n", [F])).
```

```{.prolog .query}
?- print_evidence(deadlock(A, B)).
Deadlock (Critical Sections): 103-104
  waits_for(104,critical_section,0x7ff61d13a0c0)
  critical_section(0x7ff61d13a0c0,103,2,1)
  waits_for(103,critical_section,0x7ff61d13a140)
  critical_section(0x7ff61d13a140,104,1,1)
A = 103,
B = 104 ;
false.

?- print_evidence(handle_leak(T)).
Handle Leak: event
  handle_count(4120,event,12040)
  threshold(handle_type_count,5000)
T = event ;
false.

?- print_evidence(spiking_thread(107)).
Spiking Thread: 107
  thread_time(107,3200,900)
  thread_time(100,120,40)
  thread_time(101,15,5)
  thread_time(102,8450,1230)
  thread_time(103,30,10)
  thread_time(104,25,10)
  thread_time(105,20,5)
  thread_time(106,10,5)
  thread_time(108,0,0)
  thread_time(109,40,20)
  threshold(spiking_share,25)
true ;
false.
```

```{.prolog .query}
?- forall(( member(G, [ deadlock(_, _),
                        blocked_thread(_),
                        spiking_thread(_),
                        handle_leak(_) ]),
            evidence(G, evidence(_, _, _Facts)) ),
          maplist(call, _Facts)).
true.

?- evidence(blocked_thread(101), _E),
   _E = evidence(P, I, _Facts),
   length(_Facts, N).
P = 'Blocked Thread (Software)',
I = 101,
N = 1 ;
false.
```

## 29.6 Depth-Bounded Interpretation

```{.prolog .program}
% blocked_by(?T, ?B): T waits, directly or through
% other threads, for a critical section B owns.
% Deliberately without a visited list.
blocked_by(T, B) :-
    blocks(B, T).
blocked_by(T, B) :-
    blocks(X, T),
    blocked_by(X, B).
```

```{.prolog .query}
?- blocked_by(101, B).
B = 103 ;
B = 104 ;
B = 103 ;
B = 104 ;
...
```

```{.prolog .program}
% solve_depth(+Goal, +Depth): Goal has a proof in
% which no branch uses more than Depth clauses.
solve_depth(true, _).
solve_depth((A, B), D) :-
    solve_depth(A, D),
    solve_depth(B, D).
solve_depth(\+ A, D) :-
    \+ solve_depth(A, D).
solve_depth(G, D) :-
    \+ control(G),
    (   system_goal(G)
    ->  call(G)
    ;   D > 0,
        D1 is D - 1,
        clause(G, Body),
        solve_depth(Body, D1)
    ).
```

```{.prolog .query}
?- solve_depth(blocked_by(101, B), 6).
B = 103 ;
B = 104 ;
B = 103 ;
false.

?- solve_depth(blocked_by(101, B), 3).
false.

?- findall(B, solve_depth(blocked_by(101, B), 6),
           Bs),
   sort(Bs, Set).
Bs = [103, 104, 103],
Set = [103, 104].
```

```{.prolog .query}
?- call_with_depth_limit(blocked_by(101, B), 6,
                         R).
B = 103,
R = 4 ;
B = 104,
R = 5 ;
B = 103,
R = 6 ;
R = depth_limit_exceeded.
```

## 29.7 Counting Inferences

```{.prolog .program}
% solve_count(+Goal, -N): N is the number of goals
% resolved in the proof of Goal that was found.
solve_count(G, N) :-
    solve_count(G, 0, N).

solve_count(true, N, N).
solve_count((A, B), N0, N) :-
    solve_count(A, N0, N1),
    solve_count(B, N1, N).
solve_count(\+ A, N0, N) :-
    \+ solve_count(A, 0, _),
    N is N0 + 1.
solve_count(G, N0, N) :-
    \+ control(G),
    N1 is N0 + 1,
    (   system_goal(G)
    ->  call(G),
        N = N1
    ;   clause(G, Body),
        solve_count(Body, N1, N)
    ).
```

```{.prolog .query}
?- solve_count(blocked_thread(101), N).
N = 2 ;
false.

?- solve_count(deadlock(A, B), N).
A = 103,
B = 104,
N = 12 ;
false.

?- solve_count(handle_leak(T), N).
T = event,
N = 4 ;
false.

?- solve_count(spiking_thread(107), N).
N = 11 ;
false.
```

```{.prolog .query}
?- deadlock(_, _),
   statistics(inferences, I0),
   deadlock(_, _),
   statistics(inferences, I1),
   Cost is I1 - I0.
I0 = <...>,
I1 = <...>,
Cost = 29.
```

## 29.8 A Tracing Meta-Interpreter

```{.prolog .program}
% trace_solve(+Goal): solve Goal, printing the
% four ports of each goal, indented by depth.
trace_solve(G) :-
    trace_goal(G, 0).

trace_goal(true, _).
trace_goal((A, B), D) :-
    trace_goal(A, D),
    trace_goal(B, D).
trace_goal(\+ A, D) :-
    \+ trace_goal(A, D).
trace_goal(G, D) :-
    \+ control(G),
    port(call, D, G),
    (   step(G, D),
        (   port(exit, D, G)
        ;   port(redo, D, G),
            fail
        )
    ;   port(fail, D, G),
        fail
    ).

% step(+Goal, +Depth): one resolution step.
step(G, D) :-
    (   system_goal(G)
    ->  call(G)
    ;   clause(G, Body),
        D1 is D + 1,
        trace_goal(Body, D1)
    ).

port(Port, Depth, G) :-
    Indent is Depth * 2,
    \+ \+ ( numbervars(G, 0, _,
                       [singletons(true)]),
            format("~t~*|~a ~p~n",
                   [Indent, Port, G]) ).
```

```{.prolog .query}
?- trace_solve(handle_leak(file)).
call handle_leak(file)
  call handle_count(_,file,_)
  exit handle_count(4120,file,38)
  call threshold(handle_type_count,_)
  exit threshold(handle_type_count,5000)
  call 38>5000
  fail 38>5000
  redo threshold(handle_type_count,5000)
  fail threshold(handle_type_count,_)
  redo handle_count(4120,file,38)
  fail handle_count(_,file,_)
fail handle_leak(file)
false.
```

```{.prolog .query}
?- trace_solve(owner(A, 103)).
call owner(_,103)
  call critical_section(_,103,_,_)
  exit critical_section(0x7ff61d13a0c0,103,2,1)
  call 103=\=0
  exit 103=\=0
exit owner(0x7ff61d13a0c0,103)
A = 0x7ff61d13a0c0 ;
redo owner(0x7ff61d13a0c0,103)
  redo 103=\=0
  fail 103=\=0
  redo critical_section(0x7ff61d13a0c0,103,2,1)
  fail critical_section(_,103,_,_)
fail owner(_,103)
false.
```

## 29.9 Certainty Factors

```{.prolog .program}
% frame_regularity(?TID): the top four frames
% repeat one function.
frame_regularity(TID) :-
    frame(TID, 0, M, F, _),
    frame(TID, 1, M, F, _),
    frame(TID, 2, M, F, _),
    frame(TID, 3, M, F, _).

% rule(Hypothesis, Condition, Weight)
rule(suspect(T, stack_overflow),
     frame_regularity(T), 0.3).
rule(suspect(T, stack_overflow),
     ( frame_regularity(T),
       exception_record(T, 0xc00000fd, _) ),
     0.95).
rule(suspect(T, infinite_loop),
     spiking_thread(T), 0.6).
rule(suspect(T, infinite_loop),
     ( spiking_thread(T),
       thread_state(T, running) ), 0.8).

% solve_cf(+Goal, -CF): Goal holds with
% certainty CF.
solve_cf(true, 1.0).
solve_cf((A, B), CF) :-
    solve_cf(A, CA),
    solve_cf(B, CB),
    CF is min(CA, CB).
solve_cf(G, CF) :-
    \+ control(G),
    (   \+ rule(G, _, _)
    ->  solve(G),
        CF = 1.0
    ;   rule(G, Condition, Weight),
        solve_cf(Condition, CC),
        CF is CC * Weight
    ).

% certainty(+Hypothesis, -CF): the best certainty
% any rule gives Hypothesis; fails if none does.
certainty(H, CF) :-
    aggregate_all(max(C), solve_cf(H, C), CF).
```

```{.prolog .query}
?- solve_cf(suspect(T, What), CF).
T = 107,
What = stack_overflow,
CF = 0.3 ;
T = 102,
What = infinite_loop,
CF = 0.6 ;
T = 107,
What = infinite_loop,
CF = 0.6 ;
T = 102,
What = infinite_loop,
CF = 0.8 ;
T = 107,
What = infinite_loop,
CF = 0.8 ;
false.

?- certainty(suspect(102, infinite_loop), CF).
CF = 0.8.

?- certainty(suspect(107, stack_overflow), CF).
CF = 0.3.

?- certainty(suspect(107, infinite_loop), CF).
CF = 0.8.

?- certainty(suspect(105, infinite_loop), CF).
false.
```

## 29.10 Meta-Interpreters and Analysis Pattern Networks

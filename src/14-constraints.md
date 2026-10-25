# Chapter 14. Constraints and Coroutining

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/14-constraints.md`.

## 14.1 Coroutining

```{.prolog .program}
:- [dump1].
:- [trace1].
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.
```

```{.prolog .query}
?- dif(X, a).
dif(X, a).

?- dif(X, Y), X = a.
X = a,
dif(a, Y).

?- dif(X, Y), X = a, Y = a.
false.

?- dif(f(X, b), f(a, Y)).
dif(f(X, Y), f(a, b)).
```

```{.prolog .query}
?- aggregate_all(count, ( dif(T1, T2),
     frame(T1, 0, M, F, _),
     frame(T2, 0, M, F, _) ), N).
N = 8.

?- aggregate_all(count, ( T1 \== T2,
     frame(T1, 0, M, F, _),
     frame(T2, 0, M, F, _) ), N).
N = 18.

?- dif(T1, T2),
   frame(T1, 0, ntdll, F, _),
   frame(T2, 0, ntdll, F, _),
   F == 'NtWaitForWorkViaWorkerFactory'.
T1 = 105,
T2 = 106,
F = 'NtWaitForWorkViaWorkerFactory' ;
T1 = 106,
T2 = 105,
F = 'NtWaitForWorkViaWorkerFactory' ;
false.
```

```{.prolog .query}
?- freeze(X, writeln(X)), X = 5.
5
X = 5.

?- freeze(X, writeln(X)).
freeze(X, writeln(X)).

?- freeze(X, Y is X * 2), frozen(X, G).
G = freeze(X, user:(Y is X*2)),
freeze(X, Y is X*2).

?- frozen(X, G).
G = true.
```

```{.prolog .query}
?- when(ground(T1 - T2), D is T2 - T1), T1 = 1.0.
T1 = 1.0,
when(ground(1.0-T2), D is T2-1.0).

?- when(ground(T1 - T2), D is T2 - T1),
   T2 = 1.5, T1 = 1.0.
T1 = 1.0,
T2 = 1.5,
D = 0.5.
```

## 14.2 Constraints over Integers

```{.prolog .program}
:- use_module(library(clpfd)).
```

```{.prolog .query}
?- X #= 3 + 4.
X = 7.

?- 7 #= X + 4.
X = 3.

?- X + Y #= 10.
X+Y#=10.

?- X #= Y * Y, X #= 16.
X = 16,
Y in -4\/4.
```

```{.prolog .query}
?- X in 1..10, X #> 5, X #< 8.
X in 6..7.

?- X #\= 3, X in 1..5.
X in 1..2\/4..5.

?- [X, Y] ins 0..5, X + Y #= 9.
X in 4..5,
X+Y#=9,
Y in 4..5.

?- X in 1..1000000, X * X #= 144.
X = 12.
```

```{.prolog .query}
?- X #= Y + 1, Y #= Z + 1, Z #= X + 1.
Z+1#=Y,
Y+1#=X,
X+1#=Z.
```

```{.prolog .query}
?- X in 1..10, X #> 5, X #< 8, label([X]).
X = 6 ;
X = 7.

?- [X, Y] ins 0..5, X + Y #= 9, label([X, Y]).
X = 4,
Y = 5 ;
X = 5,
Y = 4.

?- [X, Y] ins 1..3, X #< Y,
   labeling([max(Y - X)], [X, Y]).
X = 1,
Y = 3 ;
X = 1,
Y = 2 ;
X = 2,
Y = 3 ;
false.
```

```{.prolog .query}
?- X in 1..10, X #> 5,
   fd_dom(X, D), fd_size(X, N).
D = 6..10,
N = 5,
X in 6..10.
```

## 14.3 Global Constraints and Reification

```{.prolog .query}
?- X in 1..2, Y in 1..2, Z in 1..3,
   all_different([X, Y, Z]).
X in 1..2,
all_different([X, Y, Z]),
Y in 1..2,
Z in 1..3.

?- X in 1..2, Y in 1..2, Z in 1..3,
   all_distinct([X, Y, Z]).
Z = 3,
X in 1..2,
all_distinct([X, Y, 3]),
Y in 1..2.
```

```{.prolog .query}
?- [A, B, C] ins 1..3, sum([A, B, C], #=, 6),
   all_distinct([A, B, C]), A #< B, B #< C.
A = 1,
B = 2,
C = 3.

?- tuples_in([[S0, S1], [S1, S2]],
   [[0, 1], [1, 0], [1, 2]]), S0 = 0.
S0 = 0,
S1 = 1,
S2 in 0\/2.
```

```{.prolog .query}
?- B #<==> (X #> 5), X = 7.
B = 1,
X = 7.

?- B #<==> (X #> 5), X in 1..4.
B = 0,
X in 1..4.

?- X in 0..10, B #<==> (X #> 5), B = 1.
B = 1,
X in 6..10.

?- X #> 5 #==> Y #= 1, X = 6.
X = 6,
Y = 1.
```

```{.prolog .program}
% at_most(Max, Threshold, Values): at most Max of
% Values exceed Threshold.
at_most(Max, Threshold, Values) :-
    maplist(exceeds_flag(Threshold), Values,
            Flags),
    sum(Flags, #=<, Max).

exceeds_flag(Threshold, Value, Flag) :-
    Flag #<==> (Value #> Threshold).
```

```{.prolog .query}
?- Vs = [A, B, C], Vs ins 0..9, at_most(1, 5, Vs),
   A = 7.
Vs = [7, B, C],
A = 7,
B in 0..5,
C in 0..5.
```

## 14.4 Reconstructing an Event Order

```{.prolog .program}
% request_order(Events): Events pairs the seven
% lifecycle events of a report request with their
% times; the constraints are those the program
% imposes on every request.
request_order([ received-R, dispatched-D,
                query_start-QS, query_end-QE,
                build_start-BS, build_end-BE,
                completed-C ]) :-
    R #< D,
    D #< QS, QS #< QE,
    D #< BS, BS #< BE,
    QE #< C, BE #< C.
```

```{.prolog .query}
?- request_order(_Es), pairs_values(_Es, Ps),
   Ps ins 1..7, all_distinct(Ps).
Ps = [1, 2, _A, _B, _C, _D, 7],
_A in 3..5,
_A#=<_B+ -1,
all_distinct([1, 2, _A, _B, _C, _D, 7]),
_B in 4..6,
_C in 3..5,
_C#=<_D+ -1,
_D in 4..6.
```

```{.prolog .program}
% consistent_orders(Count): Count is the number of
% total orders of the seven events that satisfy
% request_order/1.
consistent_orders(Count) :-
    request_order(Es),
    pairs_values(Es, Ps),
    Ps ins 1..7,
    all_distinct(Ps),
    findall(Ps, label(Ps), Orders),
    length(Orders, Count).
```

```{.prolog .query}
?- consistent_orders(N).
N = 6.
```

```{.prolog .program}
% report_lifecycle(Events): request_order/1 with
% the knowledge that the build consumes the
% query's result.
report_lifecycle(Events) :-
    request_order(Events),
    memberchk(query_end-QE, Events),
    memberchk(build_start-BS, Events),
    QE #< BS.
```

```{.prolog .query}
?- report_lifecycle(_Es), pairs_values(_Es, Ps),
   Ps ins 1..7, all_distinct(Ps).
Ps = [1, 2, 3, 4, 5, 6, 7].
```

```{.prolog .program}
% agrees(Model, Observed): every Name-Time pair of
% Observed is consistent with the Name-Var pairs
% of Model.
agrees(Model, Observed) :-
    maplist(observed_in(Model), Observed).

observed_in(Model, Event) :-
    memberchk(Event, Model).

% feasible(Observed): the observed report request
% events could have been produced by the program.
feasible(Observed) :-
    report_lifecycle(Model),
    agrees(Model, Observed).
```

```{.prolog .program}
% ms(Seconds, Ms): Ms is Seconds as integer ms.
ms(Seconds, Ms) :-
    Ms is round(Seconds * 1000).

% request_events(R, Events): the lifecycle events
% of request R found in the trace, as Name-Ms.
request_events(R, [received-Tr, dispatched-Td
                   | Rest]) :-
    once(request_msg(R, "received", _, Tr)),
    once(request_msg(R, "dispatched", W, Td)),
    (   once(request_msg(R, "completed", W, Tc))
    ->  true
    ;   Tc = inf
    ),
    findall(Name-T,
            worker_event(W, Td, Tc, Name, T),
            Rest).

request_msg(R, Verb, TID, Ms) :-
    format(string(Prefix), "Request ~w ~s",
           [R, Verb]),
    msg(_, Time, _, TID, appserver, Text),
    string_concat(Prefix, _, Text),
    ms(Time, Ms).

worker_event(W, Td, Tc, Name, Ms) :-
    msg(_, Time, _, W, _, Text),
    ms(Time, Ms),
    Ms > Td,
    Ms =< Tc,
    event_prefix(Prefix, Name),
    string_concat(Prefix, _, Text).

event_prefix("Query start", query_start).
event_prefix("Query end", query_end).
event_prefix("Build start", build_start).
event_prefix("Build end", build_end).
event_prefix("Request", completed).
```

```{.prolog .query}
?- request_events(1, _Es),
   forall(member(Name-T, _Es),
          format("~w ~w~n", [T, Name])).
1002 received
1003 dispatched
1004 query_start
1048 query_end
1049 build_start
1310 build_end
1311 completed
true.

?- request_events(1, _Es), feasible(_Es).
true.

?- request_events(5, _Es), feasible(_Es).
true.
```

```{.prolog .query}
?- request_events(1, [A, B, QS-T1, QE-T2 | Rest]),
   feasible([A, B, QS-T2, QE-T1 | Rest]).
false.
```

```{.prolog .query}
?- request_events(1, _Es),
   selectchk(query_end-_, _Es, _Rest),
   report_lifecycle(_Model),
   agrees(_Model, _Rest),
   memberchk(query_end-QE, _Model).
QE in 1005..1048.
```

```{.prolog .query}
?- request_events(2, _Es), length(_Es, N),
   report_lifecycle(_Model),
   agrees(_Model, _Es),
   memberchk(build_end-BE, _Model),
   memberchk(completed-C, _Model).
N = 5,
BE in 1552..sup,
BE#=<C+ -1,
C in 1551..sup.
```

## 14.5 Deducing a Counter

```{.prolog .program}
:- use_module(library(pcre)).

% queue_event(N, Event): message N of the trace
% is an event of the request queue.
queue_event(N, Event) :-
    msg(N, _, _, _, appserver, Text),
    queue_text(Text, Event).

queue_text(Text, received(R)) :-
    re_matchsub("^Request (?<r_I>\\d+) received",
                Text, Sub, []),
    get_dict(r, Sub, R).
queue_text(Text, queued(R)) :-
    re_matchsub("request (?<r_I>\\d+) queued$",
                Text, Sub, []),
    get_dict(r, Sub, R).
queue_text(Text, dispatched(R)) :-
    re_matchsub("^Request (?<r_I>\\d+) dispatch",
                Text, Sub, []),
    get_dict(r, Sub, R).
queue_text(Text, depth(D)) :-
    re_matchsub("queue depth (?<d_I>\\d+)",
                Text, Sub, []),
    get_dict(d, Sub, D).

% queue_events(From, To, Events): the queue events
% of messages From to To, in order.
queue_events(From, To, Events) :-
    findall(E, ( between(From, To, N),
                 queue_event(N, E) ),
            Events).
```

```{.prolog .query}
?- forall(( between(37, 47, N),
            queue_event(N, E) ),
          format("~w ~w~n", [N, E])).
37 received(5)
38 queued(5)
39 received(6)
40 queued(6)
41 received(7)
42 queued(7)
43 depth(3)
44 received(8)
45 depth(4)
46 received(9)
47 depth(5)
true.
```

```{.prolog .program}
% depth_model(Events, D0, Final, Incs): D0 is the
% queue depth before Events and Final after them;
% Incs pairs each received request with its
% increment, 1 if it was queued.
depth_model(Events, D0, Final, Incs) :-
    D0 #>= 0,
    findall(R, member(queued(R), Events), Queued),
    depth_steps(Events, Queued, D0, Final,
                [], Incs).

depth_steps([], _, D, D, Incs, Incs).
depth_steps([E | Es], Qd, D0, D, Incs0, Incs) :-
    depth_step(E, Qd, D0, D1, Incs0, Incs1),
    depth_steps(Es, Qd, D1, D, Incs1, Incs).

depth_step(received(R), Queued, D0, D1,
           Incs, [R-I | Incs]) :-
    (   memberchk(R, Queued)
    ->  I = 1
    ;   I in 0..1
    ),
    D1 #= D0 + I.
depth_step(queued(_), _, D, D, Incs, Incs).
depth_step(depth(V), _, D, D, Incs, Incs) :-
    D #= V.
depth_step(dispatched(R), _, D0, D1, Incs,
           Incs) :-
    memberchk(R-I, Incs),
    D1 #= D0 - I,
    D1 #>= 0.
```

```{.prolog .query}
?- queue_events(37, 66, _Es),
   depth_model(_Es, D0, Final, Incs).
D0 = Final, Final = 0,
Incs = [9-1, 8-1, 7-1, 6-1, 5-1].
```

## 14.6 Thread Timelines

```{.prolog .program}
% deadlock_timeline(A1, R1, A2, R2): the times in
% ms at which 103 acquired section A, 103
% requested section B, 104 acquired B, and 104
% requested A.
deadlock_timeline(A1, R1, A2, R2) :-
    A1 #< R1,
    A2 #< R2,
    A2 #< R1,
    A1 #< R2,
    A1 #>= 2001,
    A2 #>= 2101,
    R1 #=< 9003,
    R2 #=< 9003.
```

```{.prolog .query}
?- deadlock_timeline(A1, R1, A2, R2).
A1 in 2001..9002,
A1#=<R2+ -1,
A1#=<R1+ -1,
R1 in 2102..9003,
A2#=<R1+ -1,
A2 in 2101..9002,
A2#=<R2+ -1,
R2 in 2102..9003.
```

```{.prolog .query}
?- deadlock_timeline(A1, R1, A2, R2),
   Deadlock #= max(R1, R2),
   once(labeling([min(Deadlock)],
                 [A1, R1, A2, R2, Deadlock])).
A1 = 2001,
R1 = R2, R2 = Deadlock, Deadlock = 2102,
A2 = 2101.

?- deadlock_timeline(A1, R1, A2, R2),
   Deadlock #= max(R1, R2),
   once(labeling([max(Deadlock)],
                 [A1, R1, A2, R2, Deadlock])).
A1 = 2001,
R1 = 2102,
A2 = 2101,
R2 = Deadlock, Deadlock = 9003.
```

```{.prolog .query}
?- deadlock_timeline(A1, R1, A2, R2),
   R1 #= 9003 - 7001,
   R2 #= 9003 - 6900.
false.
```

## 14.7 Diagnostic Use

```{.prolog .program}
% dblog(Time, TID, Text): the database client's
% own log of the same run; Time in ms of its own
% clock.
dblog(1265, 100, "Connecting to db01:5432").
dblog(1462, 100,
      "Connected to db01:5432, session=71").
dblog(2254, 101, "Query start: SELECT report 17").
dblog(2298, 101, "Query end: 1 row, 44 ms").
dblog(2752, 102, "Query start: SELECT report 18").
dblog(2800, 102, "Query end: 1 row, 48 ms").
dblog(3253, 103,
      "Send start: session=71, bytes=1024").
dblog(3352, 104,
      "Reply received: session=71, bytes=512").
dblog(10257, 101,
      "Query start: SELECT report 19").
dblog(10310, 101, "Query end: 1 row, 53 ms").
dblog(15251, 109, "Receive start: session=71").
dblog(15252, 109,
      "Error: buffer copy failed, code=0x3e6").

% app_msg(N, Ms): message N of the application
% log, at Ms milliseconds of the application's
% clock.
app_msg(N, Ms) :-
    msg(N, Time, _, _, Component, _),
    Component \== dbclient,
    ms(Time, Ms).
```

```{.prolog .program}
% link(Order, Text, N): the dblog message Text
% happened before or after application message N.
link(after,  "Connecting to db01:5432", 2).
link(before, "Connected to db01:5432, session=71",
     6).
link(after,  "Query start: SELECT report 17", 11).
link(before, "Query end: 1 row, 44 ms", 17).
link(after,  "Query start: SELECT report 19", 37).
link(before, "Query end: 1 row, 53 ms", 58).

% skew(S): S is the offset in ms of the database
% client's clock: its time is the application's
% time plus S.
skew(S) :-
    findall(Order-(Tdb, Tapp),
            ( link(Order, Text, N),
              dblog(Tdb, _, Text),
              app_msg(N, Tapp) ),
            Links),
    maplist(skew_link(S), Links).

skew_link(S, after-(Tdb, Tapp)) :-
    Tdb - S #> Tapp.
skew_link(S, before-(Tdb, Tapp)) :-
    Tdb - S #< Tapp.
```

```{.prolog .query}
?- skew(S).
S in 1249..1251.
```

```{.prolog .program}
% relative_order(Text, N, Order): under every
% admissible skew, the dblog message Text is
% before or after application message N;
% undetermined if the skew interval allows both.
relative_order(Text, N, Order) :-
    dblog(Tdb, _, Text),
    app_msg(N, Tapp),
    (   \+ ( skew(S), Tdb - S #>= Tapp )
    ->  Order = before
    ;   \+ ( skew(S), Tdb - S #=< Tapp )
    ->  Order = after
    ;   Order = undetermined
    ).
```

```{.prolog .query}
?- relative_order("Query start: SELECT report 17",
   11, O).
O = after.

?- relative_order("Query start: SELECT report 17",
   12, O).
O = undetermined.

?- relative_order("Query end: 1 row, 44 ms",
   16, O).
O = before.

?- aggregate_all(count,
   ( dblog(_, _, T), app_msg(N, _),
     relative_order(T, N, undetermined) ), U).
U = 11.
```

```{.prolog .program}
% print_merged(S, From, To): print both logs
% merged under skew S, for application times
% From..To.
print_merged(S, From, To) :-
    findall(T-app(Text),
            ( app_msg(N, T),
              msg(N, _, _, _, _, Text) ),
            As),
    findall(T-db(Text),
            ( dblog(Tdb, _, Text),
              T is Tdb - S ),
            Ds),
    append(As, Ds, All),
    keysort(All, Sorted),
    forall(( member(T-Event, Sorted),
             T >= From, T =< To ),
           print_event(T, Event)).

print_event(T, app(Text)) :-
    format("~w app ~w~n", [T, Text]).
print_event(T, db(Text)) :-
    format("~w db  ~w~n", [T, Text]).
```

```{.prolog .query}
?- print_merged(1250, 1000, 1320).
1002 app Request 1 received: GET /report/17
1003 app Request 1 dispatched to worker 101
1004 db  Query start: SELECT report 17
1048 db  Query end: 1 row, 44 ms
1049 app Build start: report 17
1310 app Build end: report 17, 2611 nodes, 261 ms
1311 app Request 1 completed: 200, 309 ms
true.
```

```{.prolog .query}
?- feasible([received-1002, dispatched-1003,
             query_start-954, query_end-998,
             build_start-1049, build_end-1310,
             completed-1311]).
false.
```

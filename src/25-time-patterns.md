# Chapter 25. Time

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/25-time-patterns.md`.

```{.prolog .program}
:- [trace1].
:- use_module(library(dcg/basics)).

truncated(Text, Width, Short) :-
    string_length(Text, Len),
    (   Len =< Width
    ->  Short = Text
    ;   sub_string(Text, 0, Width, _, Short)
    ).

print_row(N) :-
    msg(N, Time, _, TID, Component, Text),
    truncated(Text, 23, Short),
    format("~t~d~2| ~t~3f~9| ~d ~a~t~26| ~s~n",
           [N, Time, TID, Component, Short]).

print_messages(Ns) :-
    forall(member(N, Ns), print_row(N)).

% time_ms(N, Ms): message N was written Ms whole
% milliseconds after the trace start.
time_ms(N, Ms) :-
    msg(N, Time, _, _, _, _),
    Ms is round(Time * 1000).

% thread_messages(TID, Set): Set is the message
% set of thread TID.
thread_messages(TID, Set) :-
    bagof(N, T^P^C^X^msg(N, T, P, TID, C, X), Ns),
    sort(Ns, Set).

% trace_start(Ms), trace_end(Ms): the times of the
% first and last message.
trace_start(Start) :-
    aggregate_all(min(Ms), time_ms(_, Ms), Start).
trace_end(End) :-
    aggregate_all(max(Ms), time_ms(_, Ms), End).
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.

?- time_ms(67, Ms).
Ms = 14000.

?- thread_messages(103, S).
S = [9, 24, 25, 26].

?- trace_start(S), trace_end(E).
S = 0,
E = 14010.
```

```{.prolog .program}
% threshold(Name, Value): the thresholds of this
% chapter, in milliseconds unless stated.
threshold(discontinuity, 1000).
threshold(correlation, 100).
threshold(period_tolerance, 10).
threshold(min_period, 100).
threshold(timeout_tolerance, 5).
threshold(burst_gap, 500).
threshold(no_activity, 2000).
threshold(blackout, 2000).
```

## 25.1 Time Delta

```{.prolog .program}
% time_delta(N, Next, Delta): Next follows N in
% the trace, Delta milliseconds later.
time_delta(N, Next, Delta) :-
    time_ms(N, T1),
    Next is N + 1,
    time_ms(Next, T2),
    Delta is T2 - T1.

% time_delta(Set, N, Next, Delta): Next follows N
% in the message set Set, Delta ms later.
time_delta(Set, N, Next, Delta) :-
    nextto(N, Next, Set),
    time_ms(N, T1),
    time_ms(Next, T2),
    Delta is T2 - T1.

% print_deltas(Set): one line per adjacent pair of
% Set with the delta and the later message's text.
print_deltas(Set) :-
    forall(time_delta(Set, N, Next, Delta),
           print_delta(N, Next, Delta)).

print_delta(N, Next, Delta) :-
    msg(Next, _, _, _, _, Text),
    truncated(Text, 28, Short),
    format("~t~d~2|-~d~t~6| ~t~d~12| ~s~n",
           [N, Next, Delta, Short]).
```

```{.prolog .query}
?- time_delta(66, Next, D).
Next = 67,
D = 4691.

?- aggregate_all(max(D, N), time_delta(N, _, D),
   M).
M = max(4691, 66).

?- thread_messages(101, _S), print_deltas(_S).
 7-12    788 Request 1 dispatched to work
12-13      1 Query start: SELECT report 1
13-14     44 Query end: 1 row, 44 ms
14-15      1 Build start: report 17
15-16    261 Build end: report 17, 2611 n
16-17      1 Request 1 completed: 200, 30
17-53   7695 Request 5 dispatched to work
53-54      1 Query start: SELECT report 1
54-55     53 Query end: 1 row, 53 ms
55-56      1 Build start: report 19
56-57    239 Build end: report 19, 2402 n
57-58      1 Request 5 completed: 200, 43
58-59      1 Request 6 dispatched to work
59-60      1 Request 6 completed: 200, 33
60-61      1 Request 7 dispatched to work
61-62      1 Request 7 completed: 200, 23
62-63      1 Request 8 dispatched to work
63-64      1 Request 8 completed: 200, 13
64-65      1 Request 9 dispatched to work
65-66      1 Request 9 completed: 200, 30
true.
```

## 25.2 Discontinuity

```{.prolog .program}
% discontinuity(N, Delta): the gap after message N
% in the trace exceeds the threshold.
discontinuity(N, Delta) :-
    time_delta(N, _, Delta),
    threshold(discontinuity, Min),
    Delta > Min.

% discontinuity(Set, N, Delta): the gap after N
% within the message set Set exceeds the
% threshold.
discontinuity(Set, N, Delta) :-
    time_delta(Set, N, _, Delta),
    threshold(discontinuity, Min),
    Delta > Min.

% thread_discontinuity(TID, N, Delta): a
% discontinuity within the messages of TID.
thread_discontinuity(TID, N, Delta) :-
    thread_messages(TID, Set),
    discontinuity(Set, N, Delta).
```

```{.prolog .query}
?- discontinuity(N, D).
N = 66,
D = 4691 ;
false.

?- thread_discontinuity(T, N, D).
T = 100,
N = 27,
D = 2901 ;
T = 100,
N = 47,
D = 5009 ;
T = 101,
N = 17,
D = 7695 ;
T = 102,
N = 8,
D = 1286 ;
T = 103,
N = 9,
D = 1785 ;
T = 104,
N = 10,
D = 1885 ;
false.
```

## 25.3 Correlated Discontinuity

```{.prolog .program}
% correlated_discontinuity(T1-N1, T2-N2): the
% discontinuities after N1 in thread T1 and after
% N2 in thread T2 begin within the correlation
% threshold of each other.
correlated_discontinuity(T1-N1, T2-N2) :-
    thread_discontinuity(T1, N1, _),
    thread_discontinuity(T2, N2, _),
    T1 @< T2,
    time_ms(N1, S1),
    time_ms(N2, S2),
    threshold(correlation, Max),
    abs(S1 - S2) =< Max.
```

```{.prolog .query}
?- correlated_discontinuity(A, B).
A = 102-8,
B = 103-9 ;
A = 102-8,
B = 104-10 ;
A = 103-9,
B = 104-10 ;
false.
```

## 25.4 Statement Density and Current

```{.prolog .program}
% window_messages(+From, +To, -Set): Set is the
% set of messages with From =< Time < To; From and
% To are times in seconds, From < To.
window_messages(From, To, Set) :-
    findall(N,
            ( msg(N, T, _, _, _, _),
              T >= From, T < To ),
            Ns),
    sort(Ns, Set).

% statement_current(+From, +To, -Current): Current
% is the number of messages per second in the
% window From..To, in seconds, From < To.
statement_current(From, To, Current) :-
    window_messages(From, To, Set),
    length(Set, Count),
    Current is Count / (To - From).

% window(+Width, -From, -To): the consecutive
% windows of Width seconds covering the trace.
% Width is a positive integer number of seconds;
% From and To are then integers in seconds.
window(Width, From, To) :-
    must_be(positive_integer, Width),
    trace_end(End),
    Last is End // (Width * 1000),
    between(0, Last, I),
    From is I * Width,
    To is From + Width.

% print_current(Width): the current per window, as
% a number and as a bar.
print_current(Width) :-
    forall(window(Width, From, To),
           print_window_current(From, To)).

print_window_current(From, To) :-
    statement_current(From, To, Current),
    Stars is round(Current),
    format("~t~d~3|-~d~t~7| ~t~1f~12| ~*c~n",
           [From, To, Current, Stars, 0'*]).
```

```{.prolog .query}
?- statement_current(9, 10, C).
C = 21.

?- statement_current(10, 14, C).
C = 0.

?- print_current(1).
  0-1   10.0 **********
  1-2   12.0 ************
  2-3    9.0 *********
  3-4    2.0 **
  4-5    2.0 **
  5-6    3.0 ***
  6-7    2.0 **
  7-8    3.0 ***
  8-9    2.0 **
  9-10  21.0 *********************
 10-11   0.0
 11-12   0.0
 12-13   0.0
 13-14   0.0
 14-15   5.0 *****
true.
```

### 25.4.1 A boundary check: the window width

```{.prolog .query}
?- catch(window(0.5, _, _), error(E, _), true).
E = type_error(positive_integer, 0.5).

?- catch(window(0, _, _), error(E, _), true).
E = type_error(positive_integer, 0).

?- aggregate_all(count, window(5, _, _), C).
C = 3.
```

```{.prolog .program}
% statement_density(Template, From, To, Density):
% Density is the share of the messages in the
% window that unify with Template.
statement_density(Template, From, To, Density) :-
    window_messages(From, To, Set),
    length(Set, Total),
    Total > 0,
    Template = msg(N, _, _, _, _, _),
    aggregate_all(count,
                  ( member(N, Set), Template ),
                  Count),
    Density is Count / Total.
```

```{.prolog .query}
?- statement_density(
   msg(_, _, _, _, appserver, _), 5, 10, _D),
   format("~2f~n", [_D]).
0.84
true.

?- statement_density(msg(_, _, _, 101, _, _),
   9, 10, _D), format("~2f~n", [_D]).
0.67
true.

?- statement_density(msg(_, _, _, _, _, _),
   10, 11, D).
false.
```

## 25.5 Density Distribution

```{.prolog .program}
% density_distribution(Template, Width, Dist):
% Dist is the list of From-Density pairs for the
% non-empty windows of Width seconds.
density_distribution(Template, Width, Dist) :-
    findall(From-Density,
            window_density(Template, Width, From,
                           Density),
            Dist).

window_density(Template, Width, From, Density) :-
    window(Width, From, To),
    statement_density(Template, From, To,
                      Density).

% print_distribution(Dist): one line per window.
print_distribution(Dist) :-
    forall(member(From-Density, Dist),
           ( Stars is round(20 * Density),
             format("~t~d~3| ~t~2f~9| ~*c~n",
                    [From, Density, Stars, 0'*])
           )).
```

```{.prolog .query}
?- density_distribution(
   msg(_, _, _, _, reportengine, _), 1, _D),
   print_distribution(_D).
  0  0.00
  1  0.25 *****
  2  0.11 **
  3  1.00 ********************
  4  1.00 ********************
  5  0.33 *******
  6  0.00
  7  0.00
  8  0.00
  9  0.10 **
 14  0.00
true.

?- density_distribution(
   msg(_, _, _, _, dbclient, _), 1, _D),
   print_distribution(_D).
  0  0.20 ****
  1  0.33 *******
  2  0.22 ****
  3  0.00
  4  0.00
  5  0.00
  6  0.00
  7  0.00
  8  0.00
  9  0.10 **
 14  0.40 ********
true.
```

## 25.6 Relative Density

```{.prolog .program}
% relative_density(TemplateA, TemplateB, From, To,
% Ratio): Ratio is the number of messages matching
% TemplateA per message matching TemplateB in the
% window.
relative_density(TemplateA, TemplateB, From, To,
                 Ratio) :-
    window_messages(From, To, Set),
    TemplateA = msg(NA, _, _, _, _, _),
    TemplateB = msg(NB, _, _, _, _, _),
    aggregate_all(count,
                  ( member(NA, Set), TemplateA ),
                  CountA),
    aggregate_all(count,
                  ( member(NB, Set), TemplateB ),
                  CountB),
    CountB > 0,
    Ratio is CountA / CountB.
```

```{.prolog .query}
?- relative_density(msg(_, _, _, _, dbclient, _),
   msg(_, _, _, _, appserver, _), 0, 15, _R),
   format("~2f~n", [_R]).
0.26
true.

?- relative_density(
   msg(_, _, _, _, reportengine, _),
   msg(_, _, _, _, appserver, _), 2, 6, R).
R = 0.75.
```

## 25.7 Trace Acceleration

```{.prolog .program}
% trace_acceleration(Width, From, Acceleration):
% the current of the window after the one starting
% at From minus the current of that window.
trace_acceleration(Width, From, Acceleration) :-
    window(Width, From, To),
    statement_current(From, To, C1),
    Next is To + Width,
    statement_current(To, Next, C2),
    Acceleration is C2 - C1.

% print_acceleration(Width): one signed value per
% window boundary.
print_acceleration(Width) :-
    forall(trace_acceleration(Width, From, A),
           ( (   A >= 0
             ->  Sign = '+'
             ;   Sign = ''
             ),
             format("~t~d~3| ~t~a~w~10|~n",
                    [From, Sign, A]) )).
```

```{.prolog .query}
?- print_acceleration(1).
  0     +2
  1     -3
  2     -7
  3     +0
  4     +1
  5     -1
  6     +1
  7     -1
  8    +19
  9    -21
 10     +0
 11     +0
 12     +0
 13     +5
 14     -5
true.

?- aggregate_all(max(A, From),
   trace_acceleration(1, From, A), M).
M = max(19, 8).
```

## 25.8 Delay Dynamics

```{.prolog .program}
% completion(N, Request, Ms): message N reports
% the completion of Request in Ms milliseconds.
completion(N, Request, Ms) :-
    msg(N, _, _, _, _, Text),
    string_codes(Text, Codes),
    phrase(completion(Request, Ms), Codes).

completion(Request, Ms) -->
    "Request ", integer(Request),
    " completed: ", integer(_Status),
    ", ", integer(Ms), " ms".

% reported_duration(N, Ms): the text of message N
% ends with a duration of Ms milliseconds.
reported_duration(N, Ms) :-
    msg(N, _, _, _, _, Text),
    string_concat(Front, " ms", Text),
    split_string(Front, " ", "", Parts),
    last(Parts, Last),
    number_string(Ms, Last).

% delay_dynamics(Durations, Changes): Durations is
% the list of completion times in trace order and
% Changes their successive differences.
delay_dynamics(Durations, Changes) :-
    findall(Ms, completion(_, _, Ms), Durations),
    changes(Durations, Changes).

changes([], []).
changes([X | Xs], Changes) :-
    changes_from(Xs, X, Changes).

changes_from([], _, []).
changes_from([Y | Ys], X, [D | Ds]) :-
    D is Y - X,
    changes_from(Ys, Y, Ds).
```

```{.prolog .query}
?- completion(58, R, Ms).
R = 5,
Ms = 4300.

?- forall(completion(N, R, Ms),
   format("~t~d~3| request ~d ~t~d~22| ms~n",
          [N, R, Ms])).
 17 request 1      309 ms
 58 request 5     4300 ms
 60 request 6     3302 ms
 62 request 7     2305 ms
 64 request 8     1307 ms
 66 request 9      309 ms
true.

?- delay_dynamics(Ms, Changes).
Ms = [309, 4300, 3302, 2305, 1307, 309],
Changes = [3991, -998, -997, -998, -998].

?- reported_duration(49, Ms).
Ms = 7001.
```

## 25.9 Periodic Error

```{.prolog .program}
% error_word(Word): a word marking an error.
error_word("Error").
error_word("exception").
error_word("failed").

% error_message(N): message N contains an error
% word.
error_message(N) :-
    msg(N, _, _, _, _, Text),
    once(( error_word(Word),
           sub_string(Text, _, _, _, Word) )).

:- table message_kind/2.

% message_kind(N, Kind): the text of message N
% with every number replaced by # (Chapter 24).
message_kind(N, Kind) :-
    msg(N, _, _, _, _, Text),
    string_codes(Text, Codes),
    phrase(kind(KindCodes), Codes),
    string_codes(Kind, KindCodes).

kind(Ks) -->
    (   number_token
    ->  { Ks = [0'# | Ks1] },
        kind(Ks1)
    ;   [C]
    ->  { Ks = [C | Ks1] },
        kind(Ks1)
    ;   { Ks = [] }
    ).

number_token -->
    (   "0x"
    ->  xinteger(_)
    ;   integer(_)
    ).

% kind_messages(Kind, Set): the non-empty set of
% messages of kind Kind.
kind_messages(Kind, Set) :-
    aggregate_all(set(N), message_kind(N, Kind),
                  Set),
    Set \== [].

% periodic(Set, Period): the messages of Set, at
% least three, are Period ms apart within the
% tolerance, and Period is at least min_period.
periodic(Set, Period) :-
    Set = [_, _, _ | _],
    maplist(time_ms, Set, Times),
    changes(Times, [Period | Deltas]),
    threshold(min_period, MinPeriod),
    Period >= MinPeriod,
    threshold(period_tolerance, Tolerance),
    forall(member(D, Deltas),
           abs(D - Period) =< Tolerance).

% periodic_error(Kind, Set, Period): the error
% messages of kind Kind recur with Period.
periodic_error(Kind, Set, Period) :-
    distinct(Kind, ( error_message(N),
                     message_kind(N, Kind) )),
    kind_messages(Kind, Set),
    periodic(Set, Period).
```

```{.prolog .query}
?- findall(N, error_message(N), Ns).
Ns = [43, 45, 47, 69, 70].

?- periodic_error(K, S, P).
K = "Error: queue depth # exceeds threshold #",
S = [43, 45, 47],
P = 999 ;
false.
```

## 25.10 Periodic Message Block

```{.prolog .program}
% block_kinds(N, Length, Kinds): Kinds are the
% kinds of the Length messages from N on.
block_kinds(N, Length, Kinds) :-
    msg(N, _, _, _, _, _),
    Last is N + Length - 1,
    numlist(N, Last, Ns),
    maplist(message_kind, Ns, Kinds).

% periodic_message_block(Length, Kinds, Starts,
% Period): the block Kinds of Length messages
% starts at each message in Starts, periodically.
periodic_message_block(Length, Kinds, Starts,
                       Period) :-
    distinct(Kinds,
             block_kinds(_, Length, Kinds)),
    aggregate_all(set(N),
                  block_kinds(N, Length, Kinds),
                  Starts),
    periodic(Starts, Period).

% print_kinds(Kinds): one kind per line, indented.
print_kinds(Kinds) :-
    forall(member(Kind, Kinds),
           ( truncated(Kind, 46, Short),
             format("  ~s~n", [Short]) )).
```

```{.prolog .query}
?- periodic_message_block(1, _K, S, P),
   print_kinds(_K).
  Warning: table resize, # -> #
S = [31, 32, 33, 34, 35, 36],
P = 500 ;
  No idle worker, request # queued
S = [38, 40, 42],
P = 999 ;
  Request # received: GET /health
S = [39, 41, 44, 46],
P = 1000 ;
  Error: queue depth # exceeds threshold #
S = [43, 45, 47],
P = 999 ;
false.

?- periodic_message_block(2, _K, S, P),
   print_kinds(_K).
  Warning: table resize, # -> #
  Warning: table resize, # -> #
S = [31, 32, 33, 34, 35],
P = 500 ;
false.
```

## 25.11 Timeout

```{.prolog .program}
% timeout_value(Name, Ms): a configured timeout.
timeout_value(health_check, 1000).
timeout_value(worker_wait, 7000).

% near_timeout(Ms, Name): Ms is within tolerance
% of the timeout Name.
near_timeout(Ms, Name) :-
    timeout_value(Name, Value),
    threshold(timeout_tolerance, Tolerance),
    abs(Ms - Value) =< Tolerance.

% timeout(N, Name): message N reports a duration
% matching the timeout Name.
timeout(N, Name) :-
    reported_duration(N, Ms),
    near_timeout(Ms, Name).

% timeout(N, Next, Name): Next is the next message
% of the kind of N, and the delta between them
% matches the timeout Name.
timeout(N, Next, Name) :-
    msg(N, _, _, _, _, _),
    message_kind(N, Kind),
    kind_messages(Kind, Set),
    time_delta(Set, N, Next, Delta),
    near_timeout(Delta, Name).
```

```{.prolog .query}
?- timeout(N, Name).
N = 49,
Name = worker_wait ;
false.

?- timeout(N, Next, health_check).
N = 38,
Next = 40 ;
N = 39,
Next = 41 ;
N = 40,
Next = 42 ;
N = 41,
Next = 44 ;
N = 43,
Next = 45 ;
N = 44,
Next = 46 ;
N = 45,
Next = 47 ;
false.
```

## 25.12 Significant Interval

```{.prolog .program}
% significant_interval(N1, N2, Duration, Inside):
% Duration ms passed between messages N1 and N2,
% and Inside is the set of messages between them.
significant_interval(N1, N2, Duration, Inside) :-
    N1 < N2,
    time_ms(N1, T1),
    time_ms(N2, T2),
    Duration is T2 - T1,
    Low is N1 + 1,
    High is N2 - 1,
    (   Low =< High
    ->  numlist(Low, High, Inside)
    ;   Inside = []
    ).
```

```{.prolog .query}
?- significant_interval(22, 31, D, _I),
   print_messages(_I).
23  2.000 100 appserver    Request 3 received: POS
24  2.001 103 appserver    Request 3 dispatched to
25  2.002 103 appserver    Session 9 commit start
26  2.003 103 dbclient     Send start: session=71,
27  2.100 100 appserver    Request 4 received: GET
28  2.101 104 appserver    Request 4 dispatched to
29  2.102 104 dbclient     Reply received: session
30  2.103 104 appserver    Session 9 lookup start
D = 949.

?- significant_interval(66, 67, D, I).
D = 4691,
I = [].
```

## 25.13 Punctuated Activity

```{.prolog .program}
% bursts(Set, Bursts): Bursts divides the message
% set Set into maximal runs with no gap above the
% burst_gap threshold.
bursts([], []).
bursts([N | Ns], [Burst | Bursts]) :-
    burst(Ns, N, Burst, Rest),
    bursts(Rest, Bursts).

burst(Ns, N, [N | Burst], Rest) :-
    threshold(burst_gap, Gap),
    (   Ns = [Next | Ns1],
        time_ms(N, T1),
        time_ms(Next, T2),
        T2 - T1 =< Gap
    ->  burst(Ns1, Next, Burst, Rest)
    ;   Burst = [],
        Rest = Ns
    ).

% punctuated_activity(TID, Bursts): the messages
% of thread TID form at least two bursts.
punctuated_activity(TID, Bursts) :-
    thread_messages(TID, Set),
    bursts(Set, Bursts),
    Bursts = [_, _ | _].

% print_bursts(Bursts): one line per burst with
% its message range, size, and span in ms.
print_bursts(Bursts) :-
    forall(member(Burst, Bursts),
           print_burst(Burst)).

print_burst(Burst) :-
    Burst = [First | _],
    last(Burst, Last),
    length(Burst, Count),
    time_ms(First, T1),
    time_ms(Last, T2),
    Span is T2 - T1,
    format("~t~d~3|-~d~t~7|~t~d~10|~t~d~16| ms~n",
           [First, Last, Count, Span]).
```

```{.prolog .query}
?- punctuated_activity(101, _B), print_bursts(_B).
  7-7    1     0 ms
 12-17   6   308 ms
 53-66  14   303 ms
true.

?- punctuated_activity(100, _B), print_bursts(_B).
  1-6    6   214 ms
 11-27   4  1098 ms
 37-38   2     1 ms
 39-40   2     1 ms
 41-43   3     2 ms
 44-45   2     1 ms
 46-47   2     1 ms
 71-71   1     0 ms
true.

?- punctuated_activity(T, _B), length(_B, L).
T = 100,
L = 8 ;
T = 101,
L = 3 ;
T = 102,
L = 3 ;
T = 103,
L = 2 ;
T = 104,
L = 2 ;
false.
```

## 25.14 Milestones

```{.prolog .program}
% milestone_prefix(Prefix): the text a milestone
% message begins with.
milestone_prefix("Service starting").
milestone_prefix("Worker pool started").
milestone_prefix("Unhandled exception").
milestone_prefix("Service stopping").

% milestone(N): message N is a milestone.
milestone(N) :-
    msg(N, _, _, _, _, Text),
    milestone_prefix(Prefix),
    sub_string(Text, 0, _, _, Prefix).

% milestones(Ns): the message set of milestones.
milestones(Ns) :-
    findall(N, milestone(N), Ns0),
    sort(Ns0, Ns).
```

```{.prolog .query}
?- milestones(_Ns), print_messages(_Ns).
 1  0.000 100 appserver    Service starting, versi
 6  0.214 100 appserver    Worker pool started, th
70 14.003 109 appserver    Unhandled exception 0xc
71 14.010 100 appserver    Service stopping
true.

?- milestones(_Ns), print_deltas(_Ns).
 1-6     214 Worker pool started, threads
 6-70  13789 Unhandled exception 0xc00000
70-71      7 Service stopping
true.
```

## 25.15 Last Activity

```{.prolog .program}
% last_activity(TID, N, Age): N is the last
% message of thread TID, written Age ms before the
% trace ended.
last_activity(TID, N, Age) :-
    thread_messages(TID, Set),
    last(Set, N),
    time_ms(N, T),
    trace_end(End),
    Age is End - T.

% print_last_activity: one line per thread, the
% longest silent first.
print_last_activity :-
    forall(order_by([desc(Age)],
                    last_activity(TID, N, Age)),
           print_last(TID, N, Age)).

print_last(TID, N, Age) :-
    msg(N, _, _, _, _, Text),
    truncated(Text, 26, Short),
    format("~d~t~5|~t~d~8| ~t~d~15| ~s~n",
           [TID, N, Age, Short]).
```

```{.prolog .query}
?- print_last_activity.
103   26  12007 Send start: session=71, by
104   30  11907 Session 9 lookup start
102   36   9010 Warning: table resize, 262
108   52   5005 Housekeeping: worker 101 i
101   66   4701 Request 9 completed: 200, 
109   70      7 Unhandled exception 0xc000
100   71      0 Service stopping
true.
```

## 25.16 No Activity

```{.prolog .program}
% silence(Set, From, To): no message of Set was
% written in the interval From..To, which is
% bounded by messages of Set or the trace ends.
silence(Set, Start, T) :-
    trace_start(Start),
    Set = [First | _],
    time_ms(First, T).
silence(Set, T1, T2) :-
    nextto(N1, N2, Set),
    time_ms(N1, T1),
    time_ms(N2, T2).
silence(Set, T, End) :-
    last(Set, Last),
    time_ms(Last, T),
    trace_end(End).

% no_activity(Set, From, To): a silence of Set
% longer than the no_activity threshold.
no_activity(Set, From, To) :-
    silence(Set, From, To),
    threshold(no_activity, Min),
    To - From > Min.
```

```{.prolog .query}
?- thread_messages(103, _S),
   no_activity(_S, F, T).
F = 2003,
T = 14010.

?- thread_messages(108, _S),
   no_activity(_S, F, T).
F = 0,
T = 9002 ;
F = 9005,
T = 14010.

?- thread_messages(109, _S),
   no_activity(_S, F, T).
F = 0,
T = 14000 ;
false.

?- thread_messages(101, _S),
   no_activity(_S, F, T).
F = 1311,
T = 9006 ;
F = 9309,
T = 14010.
```

## 25.17 Blackout

```{.prolog .program}
% blackout(From-To): no message was written
% between From and To, an interval longer than the
% blackout threshold.
blackout(From-To) :-
    time_delta(N, Next, Delta),
    threshold(blackout, Min),
    Delta > Min,
    time_ms(N, From),
    time_ms(Next, To).

% blackout(Interval, Evidence): the explainer
% form, with the facts the instance rests on.
blackout(From-To, evidence('Blackout', From-To,
                           Facts)) :-
    time_delta(N, Next, Delta),
    threshold(blackout, Min),
    Delta > Min,
    time_ms(N, From),
    time_ms(Next, To),
    Facts = [time_delta(N, Next, Delta),
             threshold(blackout, Min)].

% print_evidence(Evidence): the instance and each
% supporting fact as a clause.
print_evidence(evidence(Pattern, Instance, Fs)) :-
    format("~w: ~w~n", [Pattern, Instance]),
    forall(member(Fact, Fs),
           portray_clause(Fact)).
```

```{.prolog .query}
?- blackout(I).
I = 9309-14000 ;
false.

?- blackout(_, _E), print_evidence(_E).
Blackout: 9309-14000
time_delta(66, 67, 4691).
threshold(blackout, 2000).
true ;
false.

?- blackout(_, evidence(_, _, _Facts)),
   maplist(call, _Facts).
true ;
false.
```

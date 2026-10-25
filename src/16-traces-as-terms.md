# Chapter 16. Software Traces and Logs as Knowledge Bases

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/16-traces-as-terms.md`.

## 16.1 Messages and Traces

## 16.2 The msg/6 Schema

```prolog
msg(1,  0.000, 4120, 100, appserver,
    "Service starting, version 3.2.1.0").
msg(49, 9.003, 4120, 108, appserver,
    "Housekeeping: worker 103 wait 7001 ms").
msg(50, 9.003, 4120, 108, appserver,
    "Housekeeping: worker 104 wait 6900 ms").
```

## 16.3 Loading a Text Log

```text
2026-10-03 12:00:00.215 [4120:0101] appserver: Worker 101 ready
2026-10-03 12:00:00.215 [4120:0102] appserver: Worker 102 ready
2026-10-03 12:00:00.216 [4120:0103] appserver: Worker 103 ready
2026-10-03 12:00:00.216 [4120:0104] appserver: Worker 104 ready
```

```{.prolog .program}
:- use_module(library(dcg/basics)).

% log_line(Ms, PID, TID, Component, Text)//: one
% line of the log format; Ms is the clock time in
% milliseconds since midnight.
log_line(Ms, PID, TID, Component, Text) -->
    date, " ", clock(Ms), " [",
    integer(PID), ":", integer(TID), "] ",
    string_without(":", CC), ": ",
    remainder(TC),
    { atom_codes(Component, CC),
      string_codes(Text, TC) }.

% date//: a date, read and discarded.
date -->
    digits(_), "-", digits(_), "-", digits(_).

% clock(Ms)//: hh:mm:ss.fff as milliseconds.
clock(Ms) -->
    integer(H), ":", integer(M), ":", integer(S),
    ".", digits(FC),
    { number_codes(F, FC),
      Ms is ((H * 60 + M) * 60 + S) * 1000 + F }.
```

```{.prolog .program}
% log_parts(Parts): the pieces of one log line.
log_parts(["2026-10-03 12:00:00.215 [4120:0101] ",
           "appserver: ", "Worker 101 ready"]).
log_parts(["2026-10-03 12:00:00.215 [4120:0102] ",
           "appserver: ", "Worker 102 ready"]).
log_parts(["2026-10-03 12:00:00.216 [4120:0103] ",
           "appserver: ", "Worker 103 ready"]).
log_parts(["2026-10-03 12:00:00.216 [4120:0104] ",
           "appserver: ", "Worker 104 ready"]).

% log_line(Line): Line is one line of the sample
% log, as a string.
log_line(Line) :-
    log_parts(Parts),
    atomics_to_string(Parts, Line).

% parse_line(Line, M): M is the m/5 term for Line.
parse_line(Line, m(Ms, PID, TID, C, Text)) :-
    string_codes(Line, Codes),
    phrase(log_line(Ms, PID, TID, C, Text),
           Codes).
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.

?- aggregate_all(count, log_line(_), N).
N = 4.

?- forall(log_line(L),
   ( parse_line(L, M), print(M), nl )).
m(43200215,4120,101,appserver,"Worker 101 ready")
m(43200215,4120,102,appserver,"Worker 102 ready")
m(43200216,4120,103,appserver,"Worker 103 ready")
m(43200216,4120,104,appserver,"Worker 104 ready")
true.
```

```{.prolog .program}
% log_messages(Lines, Msgs): Msgs are the msg/6
% terms for the log lines Lines, numbered from 1,
% with Time in seconds from the first message.
log_messages(Lines, Msgs) :-
    maplist(parse_line, Lines, Parsed),
    Parsed = [m(Ms0, _, _, _, _) | _],
    foldl(number_message(Ms0), Parsed, Msgs,
          1, _).

% number_message(Ms0, M, Msg, N, N1): Msg is the
% msg/6 term numbered N for the m/5 term M, with
% Time relative to Ms0; N1 is the next number.
number_message(Ms0, m(Ms, PID, TID, C, Text), Msg,
               N, N1) :-
    Time is (Ms - Ms0) / 1000.0,
    Msg = msg(N, Time, PID, TID, C, Text),
    N1 is N + 1.

% write_facts(File, Facts): write Facts to File as
% clauses, one per line.
write_facts(File, Facts) :-
    setup_call_cleanup(
        open(File, write, S),
        maplist(portray_clause(S), Facts),
        close(S)).
```

```{.prolog .query}
?- findall(L, log_line(L), _Ls),
   log_messages(_Ls, _Msgs),
   forall(member(M, _Msgs), ( print(M), nl )).
msg(1,0.0,4120,101,appserver,"Worker 101 ready")
msg(2,0.0,4120,102,appserver,"Worker 102 ready")
msg(3,0.001,4120,103,appserver,"Worker 103 ready")
msg(4,0.001,4120,104,appserver,"Worker 104 ready")
true.

?- findall(L, log_line(L), _Ls),
   log_messages(_Ls, _Msgs),
   write_facts('sample.pl', _Msgs).
true.

?- [sample].
true.

?- msg(3, T, P, TID, C, Text).
T = 0.001,
P = 4120,
TID = 103,
C = appserver,
Text = "Worker 103 ready".

?- msg(N, 0.0, _, _, _, _).
N = 1 ;
N = 2.
```

## 16.4 The Shared Trace

```{.prolog .program .fresh}
:- [trace1].
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.

?- aggregate_all(count, msg(_, _, _, _, _, _), N).
N = 71.

?- msg(1, T, P, TID, C, Text).
T = 0.0,
P = 4120,
TID = 100,
C = appserver,
Text = "Service starting, version 3.2.1.0".

?- msg(71, T, _, TID, _, Text).
T = 14.01,
TID = 100,
Text = "Service stopping".

?- aggregate_all(set(TID),
   msg(_, _, _, TID, _, _), TIDs).
TIDs = [100, 101, 102, 103, 104, 108, 109].

?- aggregate_all(count,
   distinct(C, msg(_, _, _, _, C, _)), N).
N = 4.
```

```{.prolog .query}
?- msg(N, _, _, 109, _, Text),
   format("~d ~s~n", [N, Text]), fail.
67 Request 10 received: GET /session/9/data
68 Receive start: session=71
69 Error: buffer copy failed, code=0x3e6
70 Unhandled exception 0xc0000005, thread 109
false.

?- msg(67, T, _, _, _, _), format("~3f~n", [T]).
14.000
T = 14.0.
```

## 16.5 Loading and Saving CSV

```{.prolog .program}
% message_row(Row): Row is a row/6 term for a
% message of the trace.
message_row(row(N, T, P, TID, C, Text)) :-
    msg(N, T, P, TID, C, Text).

% row_message(Row, Msg): Msg is the msg/6 term for
% the row/6 term Row read from a CSV file.
row_message(row(N, T, P, TID, C, Text0), Msg) :-
    atom_string(Text0, Text),
    Msg = msg(N, T, P, TID, C, Text).
```

```{.prolog .query}
?- findall(R, message_row(R), _Rows),
   csv_write_file('trace1.csv', _Rows).
true.

?- read_file_to_string('trace1.csv', _S, []),
   split_string(_S, "\n", "\r", _Lines),
   nth1(7, _Lines, L7), nth1(14, _Lines, L14),
   format("~s~n~s~n", [L7, L14]).
7,0.215,4120,101,appserver,Worker 101 ready
14,1.048,4120,101,<...>,"Query end: 1 row, 44 ms"
L7 = <...>,
L14 = <...>.

?- csv_read_file('trace1.csv', _Rows),
   length(_Rows, Len),
   nth1(14, _Rows, row(N, T, P, TID, C, Text)).
Len = 71,
N = 14,
T = 1.048,
P = 4120,
TID = 101,
C = dbclient,
Text = 'Query end: 1 row, 44 ms'.

?- csv_read_file('trace1.csv', _Rows),
   forall(member(R, _Rows),
          ( row_message(R, M), call(M) )).
true.
```

```{.prolog .query}
?- csv_read_file('trace1.csv', _Rows,
   [convert(false)]),
   nth1(14, _Rows, row(N, T, _, _, _, Text)).
N = '14',
T = '1.048',
Text = 'Query end: 1 row, 44 ms'.
```

## 16.6 Derived Relations

```{.prolog .program}
% delta(N1, N2, Delta): N2 is the message after N1
% in the trace and Delta the seconds between them.
delta(N1, N2, Delta) :-
    msg(N1, T1, _, _, _, _),
    N2 is N1 + 1,
    msg(N2, T2, _, _, _, _),
    Delta is T2 - T1.

% thread_messages(TID, Ns): Ns is the ordered list
% of the numbers of the messages written by TID.
thread_messages(TID, Ns) :-
    setof(N,
          T^P^C^Text^msg(N, T, P, TID, C, Text),
          Ns).

% component_messages(Component, Ns): Ns is the
% ordered list of the numbers of the messages of
% Component.
component_messages(Component, Ns) :-
    setof(N,
          T^P^TID^Text^msg(N, T, P, TID,
                           Component, Text),
          Ns).
```

```{.prolog .query}
?- delta(66, N, D).
N = 67,
D = 4.691000000000001.

?- delta(16, N, D).
N = 17,
D = 0.0009999999999998899.

?- delta(49, N, D).
N = 50,
D = 0.0.

?- delta(66, _, D), format("~3f~n", [D]).
4.691
D = 4.691000000000001.

?- aggregate_all(max(D, N1-N2), delta(N1, N2, D),
   Max).
Max = max(4.691000000000001, 66-67).
```

```{.prolog .query}
?- thread_messages(108, Ns).
Ns = [48, 49, 50, 51, 52].

?- thread_messages(109, Ns).
Ns = [67, 68, 69, 70].

?- thread_messages(107, Ns).
false.

?- thread_messages(TID, Ns), length(Ns, L),
   format("~d~t~6|~t~d~4+~n", [TID, L]), fail.
100     22
101     21
102     11
103      4
104      4
108      5
109      4
false.

?- component_messages(cachelib, Ns).
Ns = [3].

?- component_messages(C, Ns), length(Ns, L),
   format("~a~t~14|~t~d~4+~n", [C, L]), fail.
appserver       47
cachelib         1
dbclient        12
reportengine    11
false.
```

## 16.7 Indexing and Scale

```{.prolog .program .fresh}
:- [trace1].
```

```{.prolog .query}
?- predicate_property(msg(_, _, _, _, _, _),
   number_of_clauses(N)).
N = 71.

?- jiti_list(msg/6).
Predicate <...> Indexed  Buckets Speedup Flags
<...>
true.

?- msg(48, T, _, _, _, _).
T = 9.002.

?- jiti_list(msg/6).
Predicate <...> Indexed  Buckets Speedup Flags
<...>
user:msg/6 <...> 1 <...> 128 <...> 71.0
true.

?- aggregate_all(count, msg(_, _, _, 108, _, _),
   N).
N = 5.

?- jiti_list(msg/6).
Predicate <...> Indexed  Buckets Speedup Flags
<...>
user:msg/6 <...> 1 <...> 128 <...> 71.0
                 <...> 4 <...> 8 <...> 4.0
true.
```

```{.prolog .query}
?- predicate_property(msg(_, _, _, _, _, _),
   size(Bytes)).
Bytes = <...>.

?- time([trace1]).
% <...> inferences, <...> CPU in <...>
true.
```

## 16.8 Several Traces in One Knowledge Base

```{.prolog .program}
% msg(Trace, N, Time, PID, TID, Component, Text):
% the message N of the trace named Trace.
msg(trace1, N, Time, PID, TID, Component, Text) :-
    msg(N, Time, PID, TID, Component, Text).
```

```{.prolog .query}
?- msg(trace1, 71, T, _, TID, _, Text).
T = 14.01,
TID = 100,
Text = "Service stopping".

?- aggregate_all(count,
   msg(trace1, _, _, _, _, _, _), N).
N = 71.

?- aggregate_all(set(Tr),
   msg(Tr, _, _, _, _, _, _), Traces).
Traces = [trace1].
```

```prolog
msg(client1, 1, 0.000, 5200, 300, client,
    "GET /report/17").
msg(client1, 2, 0.412, 5200, 300, client,
    "200 OK, 309 ms").
```

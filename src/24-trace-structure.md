# Chapter 24. Trace Structure

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/24-trace-structure.md`.

```{.prolog .program}
:- [trace1].
:- use_module(library(dcg/basics)).

% truncated(Text, Width, Short): Short is Text cut
% to at most Width characters.
truncated(Text, Width, Short) :-
    string_length(Text, Len),
    (   Len =< Width
    ->  Short = Text
    ;   sub_string(Text, 0, Width, _, Short)
    ).

% print_row(N): print message N on one line.
print_row(N) :-
    msg(N, Time, _, TID, Component, Text),
    truncated(Text, 23, Short),
    format("~t~d~2| ~t~3f~9| ~d ~a~t~26| ~s~n",
           [N, Time, TID, Component, Short]).

% print_messages(Ns): print the messages whose
% numbers are in Ns, one per line.
print_messages(Ns) :-
    forall(member(N, Ns), print_row(N)).
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.

?- print_messages([1, 26, 71]).
 1  0.000 100 appserver    Service starting, versi
26  2.003 103 dbclient     Send start: session=71,
71 14.010 100 appserver    Service stopping
true.
```

## 24.1 Basic Facts

```{.prolog .program}
% basic_facts(Facts): Facts is a list of Key=Value
% terms describing the trace as a whole.
basic_facts(Facts) :-
    aggregate_all(count, msg(_, _, _, _, _, _),
                  Count),
    aggregate_all(min(T), msg(_, T, _, _, _, _),
                  First),
    aggregate_all(max(T), msg(_, T, _, _, _, _),
                  Last),
    aggregate_all(set(P), msg(_, _, P, _, _, _),
                  PIDs),
    aggregate_all(set(T), msg(_, _, _, T, _, _),
                  TIDs),
    aggregate_all(set(C), msg(_, _, _, _, C, _),
                  Cs),
    Duration is Last - First,
    Facts = [messages=Count, first=First,
             last=Last, duration=Duration,
             processes=PIDs, threads=TIDs,
             components=Cs].

% print_basic_facts: one line per basic fact;
% lists are printed as their lengths.
print_basic_facts :-
    basic_facts(Facts),
    forall(member(Key=Value, Facts),
           print_basic_fact(Key, Value)).

print_basic_fact(Key, Value) :-
    (   is_list(Value)
    ->  length(Value, Len),
        format("~a~t~12|~d~n", [Key, Len])
    ;   float(Value)
    ->  format("~a~t~12|~3f~n", [Key, Value])
    ;   format("~a~t~12|~w~n", [Key, Value])
    ).
```

```{.prolog .query}
?- print_basic_facts.
messages    71
first       0.000
last        14.010
duration    14.010
processes   1
threads     7
components  4
true.

?- basic_facts(_F), memberchk(threads=Ts, _F).
Ts = [100, 101, 102, 103, 104, 108, 109].
```

## 24.2 Trace Dimension

```{.prolog .program}
% dimension(Dim): Dim is a dimension of the trace
% along which messages are grouped.
dimension(process).
dimension(thread).
dimension(component).

% dimension_value(Dim, N, Value): message N has
% Value along dimension Dim.
dimension_value(process, N, PID) :-
    msg(N, _, PID, _, _, _).
dimension_value(thread, N, TID) :-
    msg(N, _, _, TID, _, _).
dimension_value(component, N, C) :-
    msg(N, _, _, _, C, _).

% trace_dimension(Dim, Values): Values is the set
% of values occurring along Dim.
trace_dimension(Dim, Values) :-
    dimension(Dim),
    aggregate_all(set(V),
                  dimension_value(Dim, _, V),
                  Values).

% dimension_size(Dim, Size): Size is the number of
% distinct values along Dim.
dimension_size(Dim, Size) :-
    trace_dimension(Dim, Values),
    length(Values, Size).
```

```{.prolog .query}
?- trace_dimension(component, C).
C = [appserver, cachelib, dbclient, reportengine].

?- dimension_size(D, S).
D = process,
S = 1 ;
D = thread,
S = 7 ;
D = component,
S = 4.
```

## 24.3 Message Set

```{.prolog .program}
% message_set(Template, Set): Set is the set of
% numbers of the messages unifying with Template,
% a msg/6 term with variables for the free fields.
message_set(Template, Set) :-
    Template = msg(N, _, _, _, _, _),
    findall(N, Template, Ns),
    sort(Ns, Set).

% text_set(Sub, Set): Set is the set of messages
% whose text contains the string Sub.
text_set(Sub, Set) :-
    findall(N,
            ( msg(N, _, _, _, _, Text),
              sub_string(Text, _, _, _, Sub) ),
            Ns),
    sort(Ns, Set).
```

```{.prolog .query}
?- message_set(msg(_, _, _, 101, dbclient, _), S).
S = [13, 14, 54, 55].

?- text_set("Error", S).
S = [43, 45, 47, 69].

?- message_set(msg(_, _, _, 101, _, _), _A),
   text_set("Request", _B),
   ord_intersection(_A, _B, C), length(C, L).
C = [12, 17, 53, 58, 59, 60, 61, 62, 63|...],
L = 12.

?- text_set("Request", _A), text_set("Error", _B),
   ord_union(_A, _B, _U), length(_U, L).
L = 29.
```

## 24.4 Vocabulary Index

```{.prolog .program}
% word_separators(Seps): the characters at which
% message text is split into words.
word_separators(" ,:=/\\.()->%").

% word_of(N, Word): Word is a lowercased word of
% the text of message N.
word_of(N, Word) :-
    msg(N, _, _, _, _, Text),
    word_separators(Seps),
    split_string(Text, Seps, Seps, Parts),
    member(Part, Parts),
    Part \== "",
    string_lower(Part, Word).

% lexical(Word): Word begins with a letter.
lexical(Word) :-
    string_code(1, Word, C),
    code_type(C, alpha).

% word_messages(Word, Set): Set is the non-empty
% set of messages containing Word.
word_messages(Word, Set) :-
    aggregate_all(set(N), word_of(N, Word), Set),
    Set \== [].

% vocabulary_index(Index): Index is the list of
% Word-Set pairs, one per distinct word, in the
% standard order of the words.
vocabulary_index(Index) :-
    findall(Word-N, word_of(N, Word), Pairs),
    keysort(Pairs, Sorted),
    group_pairs_by_key(Sorted, Groups),
    maplist(dedupe, Groups, Index).

dedupe(Word-Ns, Word-Set) :-
    sort(Ns, Set).

% print_vocabulary(Max): the Max most frequent
% lexical words with their message counts.
print_vocabulary(Max) :-
    vocabulary_index(Index),
    forall(limit(Max,
                 order_by([desc(Count)],
                          frequent(Index, Word,
                                   Count))),
           format("~t~d~3| ~s~n", [Count, Word])).

frequent(Index, Word, Count) :-
    member(Word-Set, Index),
    lexical(Word),
    length(Set, Count).
```

```{.prolog .query}
?- vocabulary_index(_I), length(_I, N).
N = 118.

?- aggregate_all(count,
   ( vocabulary_index(_I), member(W-_, _I),
     lexical(W) ), N).
N = 69.

?- print_vocabulary(8).
 28 request
 21 worker
 13 ms
 11 received
 11 report
 11 to
 10 start
  9 dispatched
true.

?- word_messages("error", S).
S = [43, 45, 47, 69].

?- word_messages("session", S).
S = [5, 23, 25, 26, 27, 29, 30, 67, 68].

?- word_messages("nonesuch", S).
false.
```

## 24.5 Trace Partition

```{.prolog .program}
% trace_partition(Dim, Partition): Partition is
% the list of Value-Set pairs dividing the trace
% by its values along Dim.
trace_partition(Dim, Partition) :-
    findall(V-N, dimension_value(Dim, N, V),
            Pairs),
    keysort(Pairs, Sorted),
    group_pairs_by_key(Sorted, Partition).

% print_partition(Partition): one line per part
% with its size and first and last message.
print_partition(Partition) :-
    forall(member(Part, Partition),
           print_part(Part)).

print_part(V-Set) :-
    length(Set, Len),
    Set = [First | _],
    last(Set, Last),
    format("~w~t~14|~t~d~4+~t~d~5+~t~d~5+~n",
           [V, Len, First, Last]).
```

```{.prolog .query}
?- trace_partition(component, _P),
   print_partition(_P).
appserver       47    1   71
cachelib         1    3    3
dbclient        12    4   69
reportengine    11   15   57
true.

?- trace_partition(thread, _P),
   print_partition(_P).
100             22    1   71
101             21    7   66
102             11    8   36
103              4    9   26
104              4   10   30
108              5   48   52
109              4   67   70
true.
```

```{.prolog .program}
% exhaustive(Sets): the union of Sets is the whole
% trace.
exhaustive(Sets) :-
    foldl(ord_union, Sets, [], Union),
    message_set(msg(_, _, _, _, _, _), Union).

% disjoint(Sets): no two sets in Sets share a
% message.
disjoint([]).
disjoint([Set | Sets]) :-
    foldl(ord_union, Sets, [], Rest),
    ord_disjoint(Set, Rest),
    disjoint(Sets).
```

```{.prolog .query}
?- trace_partition(thread, _P),
   pairs_values(_P, _Sets),
   exhaustive(_Sets), disjoint(_Sets).
true.

?- vocabulary_index(_I), pairs_values(_I, _Sets),
   disjoint(_Sets).
false.
```

## 24.6 Message Space

```{.prolog .program}
% message_space(Space): Space is the set of all
% messages of the trace.
message_space(Space) :-
    message_set(msg(_, _, _, _, _, _), Space).

% coordinates(N, Point): Point locates message N
% along the ordered and grouped dimensions.
coordinates(N, point(N, Time, PID, TID, C)) :-
    msg(N, Time, PID, TID, C, _).
```

```{.prolog .query}
?- message_space(_S), length(_S, L).
L = 71.

?- coordinates(26, P).
P = point(26, 2.003, 4120, 103, dbclient).

?- message_space(_S),
   message_set(msg(_, _, _, 108, _, _), _T),
   ord_subset(_T, _S),
   ord_subtract(_S, _T, _Rest), length(_Rest, L).
L = 66.
```

## 24.7 Head of a Message Set

```{.prolog .program}
% head_message(Set, N): N is the first message of
% the non-empty message set Set.
head_message([N | _], N).
```

```{.prolog .query}
?- message_space(_S), head_message(_S, N),
   print_messages([N]).
 1  0.000 100 appserver    Service starting, versi
N = 1.

?- trace_partition(thread, _P),
   forall(member(_-_Set, _P),
          ( head_message(_Set, N),
            print_messages([N]) )).
 1  0.000 100 appserver    Service starting, versi
 7  0.215 101 appserver    Worker 101 ready
 8  0.215 102 appserver    Worker 102 ready
 9  0.216 103 appserver    Worker 103 ready
10  0.216 104 appserver    Worker 104 ready
48  9.002 108 appserver    Housekeeping: watchdog,
67 14.000 109 appserver    Request 10 received: GE
true.
```

## 24.8 Tail of a Message Set

```{.prolog .program}
% tail_message(Set, N): N is the last message of
% the non-empty message set Set.
tail_message(Set, N) :-
    last(Set, N).
```

```{.prolog .query}
?- message_space(_S), tail_message(_S, N),
   print_messages([N]).
71 14.010 100 appserver    Service stopping
N = 71.

?- trace_partition(thread, _P),
   forall(member(_-_Set, _P),
          ( tail_message(_Set, N),
            print_messages([N]) )).
71 14.010 100 appserver    Service stopping
66  9.309 101 appserver    Request 9 completed: 20
36  5.000 102 reportengine Warning: table resize,
26  2.003 103 dbclient     Send start: session=71,
30  2.103 104 appserver    Session 9 lookup start
52  9.005 108 appserver    Housekeeping: worker 10
70 14.003 109 appserver    Unhandled exception 0xc
true.
```

## 24.9 Trace Frames

```{.prolog .program}
% trace_frames(+Size, -Frames): Frames is the list
% of I-Set pairs dividing the trace into
% consecutive sets of Size messages; the last may
% be shorter. Size is a number of messages, a
% positive integer; any other value is an error.
trace_frames(Size, Frames) :-
    must_be(positive_integer, Size),
    message_space(Space),
    frames(Space, Size, 1, Frames).

frames([], _, _, []).
frames([N | Ns], Size, I, [I-Frame | Frames]) :-
    (   length(Prefix, Size),
        append(Prefix, Suffix, [N | Ns])
    ->  Frame = Prefix,
        Rest = Suffix
    ;   Frame = [N | Ns],
        Rest = []
    ),
    I1 is I + 1,
    frames(Rest, Size, I1, Frames).

% trace_frame(Size, I, Frame): Frame is frame I.
trace_frame(Size, I, Frame) :-
    trace_frames(Size, Frames),
    memberchk(I-Frame, Frames).
```

```{.prolog .query}
?- trace_frames(10, _F), length(_F, L).
L = 8.

?- trace_frame(10, 8, F).
F = [71].

?- trace_frame(10, 2, _F), print_messages(_F).
11  1.002 100 appserver    Request 1 received: GET
12  1.003 101 appserver    Request 1 dispatched to
13  1.004 101 dbclient     Query start: SELECT rep
14  1.048 101 dbclient     Query end: 1 row, 44 ms
15  1.049 101 reportengine Build start: report 17
16  1.310 101 reportengine Build end: report 17, 2
17  1.311 101 appserver    Request 1 completed: 20
18  1.500 100 appserver    Request 2 received: GET
19  1.501 102 appserver    Request 2 dispatched to
20  1.502 102 dbclient     Query start: SELECT rep
true.
```

### 24.9.1 A boundary check: the frame size

```{.prolog .query}
?- catch(trace_frames(0, _), error(E, _), true).
E = type_error(positive_integer, 0).

?- catch(trace_frames(2.5, _), error(E, _), true).
E = type_error(positive_integer, 2.5).

?- trace_frames(100, _F), length(_F, L).
L = 1.
```

## 24.10 Focus of Tracing

```{.prolog .program}
% focus(Focus): the current focus of analysis:
% thread(TID), component(C) or interval(From, To).
focus(thread(102)).

% in_focus(N): message N is within the focus.
in_focus(N) :-
    focus(Focus),
    focus_member(Focus, N).

focus_member(thread(TID), N) :-
    msg(N, _, _, TID, _, _).
focus_member(component(C), N) :-
    msg(N, _, _, _, C, _).
focus_member(interval(From, To), N) :-
    msg(N, T, _, _, _, _),
    From =< T, T =< To.

% focus_of_tracing(Set): Set is the message set
% within the focus.
focus_of_tracing(Set) :-
    findall(N, in_focus(N), Ns),
    sort(Ns, Set).
```

```{.prolog .query}
?- focus_of_tracing(_S), print_messages(_S).
 8  0.215 102 appserver    Worker 102 ready
19  1.501 102 appserver    Request 2 dispatched to
20  1.502 102 dbclient     Query start: SELECT rep
21  1.550 102 dbclient     Query end: 1 row, 48 ms
22  1.551 102 reportengine Build start: report 18
31  2.500 102 reportengine Warning: table resize,
32  3.000 102 reportengine Warning: table resize,
33  3.500 102 reportengine Warning: table resize,
34  4.000 102 reportengine Warning: table resize,
35  4.500 102 reportengine Warning: table resize,
36  5.000 102 reportengine Warning: table resize,
true.
```

## 24.11 Trace Mask

```{.prolog .program}
% trace_mask(Hidden, Visible): Visible is the set
% of messages not written by a component in the
% list Hidden.
trace_mask(Hidden, Visible) :-
    findall(N,
            ( msg(N, _, _, _, C, _),
              \+ memberchk(C, Hidden) ),
            Ns),
    sort(Ns, Visible).
```

```{.prolog .query}
?- trace_mask([reportengine], _V), length(_V, L).
L = 60.

?- trace_mask([reportengine], _V),
   trace_frame(10, 4, _F),
   ord_intersection(_F, _V, _R),
   print_messages(_R).
37  5.001 100 appserver    Request 5 received: GET
38  5.002 100 appserver    No idle worker, request
39  6.000 100 appserver    Request 6 received: GET
40  6.001 100 appserver    No idle worker, request
true.

?- text_set("Warning", _W), message_space(_S),
   ord_subtract(_S, _W, _V), length(_V, L).
L = 65.
```

## 24.12 Trace Extension

```{.prolog .program}
% extension_msg(N, Time, PID, TID, Component,
% Text): messages recorded after trace1 ends.
extension_msg(72, 14.011, 4120, 100, appserver,
    "Worker pool stopping").
extension_msg(73, 14.512, 4120, 100, dbclient,
    "Disconnected from db01:5432, session=71").
extension_msg(74, 14.513, 4120, 100, appserver,
    "Service stopped").

% trace_extension(Added): Added is the set of
% extension messages numbered after the trace.
trace_extension(Added) :-
    message_space(Space),
    tail_message(Space, Last),
    findall(N,
            ( extension_msg(N, _, _, _, _, _),
              N > Last ),
            Ns),
    sort(Ns, Added).

% extended_span(First, Last): the time span of the
% trace together with its extension.
extended_span(First, Last) :-
    aggregate_all(min(T), msg(_, T, _, _, _, _),
                  First),
    aggregate_all(max(T), any_msg(T), Last).

any_msg(T) :- msg(_, T, _, _, _, _).
any_msg(T) :- extension_msg(_, T, _, _, _, _).
```

```{.prolog .query}
?- trace_extension(A).
A = [72, 73, 74].

?- extended_span(First, Last).
First = 0.0,
Last = 14.513.
```

## 24.13 Truncated Trace

```{.prolog .program}
% start_marker(Prefix), end_marker(Prefix): the
% text a complete trace begins and ends with.
start_marker("Service starting").
end_marker("Service stopping").

% marked(N, Marker): the text of message N begins
% with the prefix given by the fact Marker/1.
marked(N, Marker) :-
    msg(N, _, _, _, _, Text),
    call(Marker, Prefix),
    sub_string(Text, 0, _, _, Prefix).

% truncated_trace(Set, Where): the message set
% Set, read as a trace, is cut at Where (start or
% end).
truncated_trace(Set, start) :-
    head_message(Set, N),
    \+ marked(N, start_marker).
truncated_trace(Set, end) :-
    tail_message(Set, N),
    \+ marked(N, end_marker).
```

```{.prolog .query}
?- message_space(_S), truncated_trace(_S, W).
false.

?- trace_frame(20, 2, _F), truncated_trace(_F, W).
W = start ;
W = end.

?- trace_frame(20, 1, _F), truncated_trace(_F, W).
W = end.
```

## 24.14 Sparse Trace

```{.prolog .program}
% threshold(Name, Value): the thresholds of this
% chapter.
threshold(sparse_trace, 1.0).

% message_rate(Set, Rate): Rate is the number of
% messages of Set per second of its span.
message_rate(Set, Rate) :-
    head_message(Set, First),
    tail_message(Set, Last),
    msg(First, T1, _, _, _, _),
    msg(Last, T2, _, _, _, _),
    T2 > T1,
    length(Set, Count),
    Rate is Count / (T2 - T1).

% sparse_trace(Set): the rate of Set is below the
% sparse_trace threshold.
sparse_trace(Set) :-
    message_rate(Set, Rate),
    threshold(sparse_trace, Min),
    Rate < Min.
```

```{.prolog .query}
?- message_space(_S), message_rate(_S, _R),
   format("~2f~n", [_R]).
5.07
true.

?- message_space(_S), sparse_trace(_S).
false.

?- text_set("Error", _E), message_rate(_E, _R),
   format("~2f~n", [_R]).
0.57
true.

?- text_set("Error", _E), sparse_trace(_E).
true.
```

## 24.15 Visibility Limit

```{.prolog .program}
:- [dump1].
```

```{.prolog .query}
?- thread(T, _), \+ msg(_, _, _, T, _, _).
T = 105 ;
T = 106 ;
T = 107 ;
false.

?- msg(_, _, _, T, _, _), \+ thread(T, _).
false.
```

## 24.16 Empty Trace

```{.prolog .program}
% empty_trace(Set): the message set Set is empty.
empty_trace([]).
```

```{.prolog .query}
?- message_set(msg(_, _, _, _, netlib, _), S),
   empty_trace(S).
S = [].

?- message_set(msg(_, _, _, 107, _, _), S),
   empty_trace(S).
S = [].

?- \+ msg(_, _, _, _, _, _).
false.
```

## 24.17 Singleton Event

```{.prolog .program}
% message_kind(N, Kind): Kind is the text of
% message N with every number replaced by #.
:- table message_kind/2.

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

% kind_messages(Kind, Set): Set is the non-empty
% set of messages of kind Kind.
kind_messages(Kind, Set) :-
    aggregate_all(set(N), message_kind(N, Kind),
                  Set),
    Set \== [].

% singleton_event(N): message N is the only one of
% its kind.
singleton_event(N) :-
    message_kind(N, Kind),
    kind_messages(Kind, [N]).
```

```{.prolog .query}
?- message_kind(58, K).
K = "Request # completed: #, # ms".

?- message_kind(69, K).
K = "Error: buffer copy failed, code=#".

?- kind_messages("Query end: # row, # ms", S).
S = [14, 21, 55].

?- aggregate_all(count, singleton_event(_), N).
N = 20.

?- aggregate_all(set(N),
   ( singleton_event(N), N > 40 ), _S),
   print_messages(_S).
48  9.002 108 appserver    Housekeeping: watchdog,
51  9.004 108 appserver    Housekeeping: worker 10
52  9.005 108 appserver    Housekeeping: worker 10
67 14.000 109 appserver    Request 10 received: GE
68 14.001 109 dbclient     Receive start: session=
69 14.002 109 dbclient     Error: buffer copy fail
70 14.003 109 appserver    Unhandled exception 0xc
71 14.010 100 appserver    Service stopping
true.
```

## 24.18 Message Directory

```{.prolog .program}
% message_directory(Directory): Directory is the
% list of Kind-Set pairs, one per message kind, in
% the standard order of the kinds; each Set is in
% message order.
message_directory(Directory) :-
    findall(Kind-N, message_kind(N, Kind), Pairs),
    sort(Pairs, Sorted),
    group_pairs_by_key(Sorted, Directory).

% print_directory(Directory): one line per kind
% with its count and first occurrence.
print_directory(Directory) :-
    forall(member(Kind-Ns, Directory),
           ( length(Ns, Count),
             Ns = [First | _],
             truncated(Kind, 40, Short),
             format("~t~d~3| ~t~d~7| ~s~n",
                    [Count, First, Short]) )).
```

```{.prolog .query}
?- message_directory(_D), length(_D, L).
L = 33.

?- message_directory(_D),
   include([_-[_, _ | _]]>>true, _D, _Repeated),
   print_directory(_Repeated).
  2  16 Build end: report #, # nodes, # ms
  3  15 Build start: report #
  3  43 Error: queue depth # exceeds threshold #
  2  49 Housekeeping: worker # wait # ms
  3  38 No idle worker, request # queued
  3  14 Query end: # row, # ms
  3  13 Query start: SELECT report #
  6  17 Request # completed: #, # ms
  9  12 Request # dispatched to worker #
  4  39 Request # received: GET /health
  3  11 Request # received: GET /report/#
  6  31 Warning: table resize, # -> #
  4   7 Worker # ready
true.
```

### 24.18.1 A boundary check: first occurrences

```{.prolog .query}
?- keysort([b-2, a-3, b-1, a-1], S).
S = [a-3, a-1, b-2, b-1].

?- sort([b-2, a-3, b-1, a-1], S).
S = [a-1, a-3, b-1, b-2].
```

```{.prolog .query}
?- message_directory(_D),
   forall(member(K-[F | _], _D),
          aggregate_all(min(N),
                        message_kind(N, K), F)).
true.
```

## 24.19 Trace Summary

```{.prolog .program}
% trace_summary: print a summary of the trace.
trace_summary :-
    print_basic_facts,
    forall(dimension(Dim),
           ( trace_partition(Dim, Partition),
             format("by ~a~n", [Dim]),
             print_partition(Partition) )),
    message_directory(Directory),
    length(Directory, Kinds),
    aggregate_all(count, singleton_event(_),
                  Singletons),
    text_set("Error", Errors),
    length(Errors, ErrorCount),
    format("kinds~t~12|~d~n", [Kinds]),
    format("singletons~t~12|~d~n", [Singletons]),
    format("errors~t~12|~d ~w~n",
           [ErrorCount, Errors]).
```

```{.prolog .query}
?- trace_summary.
messages    71
first       0.000
last        14.010
duration    14.010
processes   1
threads     7
components  4
by process
4120            71    1   71
by thread
100             22    1   71
101             21    7   66
102             11    8   36
103              4    9   26
104              4   10   30
108              5   48   52
109              4   67   70
by component
appserver       47    1   71
cachelib         1    3    3
dbclient        12    4   69
reportengine    11   15   57
kinds       33
singletons  20
errors      4 [43,45,47,69]
true.
```

## 24.20 Trace Viewpoints

```{.prolog .program}
% trace_viewpoint(Dim, Set, View): View is the
% list of Value-Subset pairs dividing the message
% set Set by its values along Dim.
trace_viewpoint(Dim, Set, View) :-
    findall(V-N,
            ( member(N, Set),
              dimension_value(Dim, N, V) ),
            Pairs),
    keysort(Pairs, Sorted),
    group_pairs_by_key(Sorted, View).

% print_view(View): each part under its value.
print_view(View) :-
    forall(member(V-Ns, View),
           ( format("~w~n", [V]),
             print_messages(Ns) )).
```

```{.prolog .query}
?- trace_frame(10, 3, _F),
   trace_viewpoint(thread, _F, _V),
   print_view(_V).
100
23  2.000 100 appserver    Request 3 received: POS
27  2.100 100 appserver    Request 4 received: GET
102
21  1.550 102 dbclient     Query end: 1 row, 48 ms
22  1.551 102 reportengine Build start: report 18
103
24  2.001 103 appserver    Request 3 dispatched to
25  2.002 103 appserver    Session 9 commit start
26  2.003 103 dbclient     Send start: session=71,
104
28  2.101 104 appserver    Request 4 dispatched to
29  2.102 104 dbclient     Reply received: session
30  2.103 104 appserver    Session 9 lookup start
true.

?- trace_frame(10, 3, _F),
   trace_viewpoint(component, _F, _V),
   print_view(_V).
appserver
23  2.000 100 appserver    Request 3 received: POS
24  2.001 103 appserver    Request 3 dispatched to
25  2.002 103 appserver    Session 9 commit start
27  2.100 100 appserver    Request 4 received: GET
28  2.101 104 appserver    Request 4 dispatched to
30  2.103 104 appserver    Session 9 lookup start
dbclient
21  1.550 102 dbclient     Query end: 1 row, 48 ms
26  2.003 103 dbclient     Send start: session=71,
29  2.102 104 dbclient     Reply received: session
reportengine
22  1.551 102 reportengine Build start: report 18
true.
```

## 24.21 Working Set

```{.prolog .program}
% working_set(Set, Components): Components is the
% set of components with a message in Set.
working_set(Set, Components) :-
    aggregate_all(set(C),
                  ( member(N, Set),
                    msg(N, _, _, _, C, _) ),
                  Components).

% print_working_sets(Frames): one line per frame
% with its message range and working set.
print_working_sets(Frames) :-
    forall(member(Frame, Frames),
           print_working_set(Frame)).

print_working_set(I-Set) :-
    working_set(Set, Cs),
    Set = [First | _],
    last(Set, Last),
    atomic_list_concat(Cs, ' ', Line),
    format("~t~d~2| ~t~d~6|-~d~t~13|~a~n",
           [I, First, Last, Line]).
```

```{.prolog .query}
?- trace_frames(10, _F), print_working_sets(_F).
 1   1-10    appserver cachelib dbclient
 2  11-20    appserver dbclient reportengine
 3  21-30    appserver dbclient reportengine
 4  31-40    appserver reportengine
 5  41-50    appserver
 6  51-60    appserver dbclient reportengine
 7  61-70    appserver dbclient
 8  71-71    appserver
true.

?- trace_frame(10, 5, _F), working_set(_F, W).
W = [appserver].
```

## 24.22 Paratext

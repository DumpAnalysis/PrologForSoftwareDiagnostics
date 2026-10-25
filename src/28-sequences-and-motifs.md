# Chapter 28. Sequences, Motifs, and Correlation

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/28-sequences-and-motifs.md`.

```{.prolog .program}
:- [trace1].

% text_of(?N, ?Text): the text of message N.
text_of(N, Text) :-
    msg(N, _, _, _, _, Text).

% invariant(+Text, -Inv): Text with every number
% replaced by #, as in Chapter 27.
invariant(Text, Inv) :-
    string_codes(Text, Codes),
    blank_numbers(Codes, Skeleton),
    string_codes(Inv, Skeleton).

blank_numbers([], []).
blank_numbers([C|Cs], Skeleton) :-
    (   code_type(C, digit)
    ->  skip_number(Cs, Rest),
        Skeleton = [0'#|Skeleton1],
        blank_numbers(Rest, Skeleton1)
    ;   Skeleton = [C|Skeleton1],
        blank_numbers(Cs, Skeleton1)
    ).

skip_number(Cs, Rest) :-
    (   Cs = [C|Cs1],
        (   code_type(C, alnum)
        ;   C == 0'.
        )
    ->  skip_number(Cs1, Rest)
    ;   Rest = Cs
    ).

% kind(?N, ?Kind): the kind atom of message N.
kind(N, Kind) :-
    text_of(N, Text),
    invariant(Text, Inv),
    kind_of(Inv, Kind).

% kind_prefix(?Kind, ?Prefix): a message whose
% invariant begins with Prefix is of kind Kind.
kind_prefix(received, "Request # received").
kind_prefix(dispatched, "Request # dispatched").
kind_prefix(completed, "Request # completed").
kind_prefix(query_start, "Query start").
kind_prefix(query_end, "Query end").
kind_prefix(build_start, "Build start").
kind_prefix(build_end, "Build end").
kind_prefix(resize, "Warning: table").
kind_prefix(queued, "No idle").
kind_prefix(error, "Error:").

% kind_of(+Inv, ?Kind): Kind is the kind whose
% prefix Inv begins with, or other if none does.
% The kind is found in a fresh variable and
% unified with Kind only after the commitment.
kind_of(Inv, Kind) :-
    (   kind_prefix(Kind0, Prefix),
        sub_string(Inv, 0, _, _, Prefix)
    ->  Kind = Kind0
    ;   Kind = other
    ).

% trace_thread(-TID): every thread, once each.
trace_thread(TID) :-
    distinct(TID, msg(_, _, _, TID, _, _)).

% thread_sequence(+TID, -Ns): message numbers of
% thread TID in order.
thread_sequence(TID, Ns) :-
    findall(N, msg(N, _, _, TID, _, _), Ns0),
    sort(Ns0, Ns).

% thread_kinds(+TID, -Kinds): the kinds of thread
% TID's messages in order.
thread_kinds(TID, Kinds) :-
    thread_sequence(TID, Ns),
    maplist(kind, Ns, Kinds).

% print_messages(+Ns): one line per message.
print_messages(Ns) :-
    forall(member(N, Ns), print_msg(N)).

print_msg(N) :-
    msg(N, _, _, TID, _, Text),
    format("~t~d~3| ~d ~s~n", [N, TID, Text]).

% print_kinds(+Ks): the kinds of a sequence, one
% per line with its position, so a long sequence
% stays within the page.
print_kinds(Ks) :-
    forall(nth1(I, Ks, K),
           format("~t~d~3| ~a~n", [I, K])).

% run_counts(+Sorted, -Counts): X-N per run of N
% equal elements X, as in Chapter 9.
run_counts([], []).
run_counts([X|Xs], [X-N|Counts]) :-
    run_length(Xs, X, 1, N, Rest),
    run_counts(Rest, Counts).

run_length(Xs, X, N0, N, Rest) :-
    (   Xs = [Y|Xs1],
        Y == X
    ->  N1 is N0 + 1,
        run_length(Xs1, X, N1, N, Rest)
    ;   N = N0,
        Rest = Xs
    ).
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.

?- thread_kinds(101, _Kinds), length(_Kinds, N).
N = 21.

?- kind(69, K).
K = error.
```

```{.prolog .query}
?- kind(11, K).
K = received.

?- kind(11, received).
true.

?- kind(11, other).
false.

?- aggregate_all(count, kind(_, other), C).
C = 22.

?- aggregate_all(count,
   ( kind(_, K), K == other ), C).
C = 22.

?- setof(K, N^kind(N, K), _Ks),
   forall(msg(N, _, _, _, _, _),
          ( aggregate_all(count, kind(N, _), 1),
            aggregate_all(count,
                ( member(K, _Ks), kind(N, K) ),
                1) )).
true.
```

## 28.1 Event Sequence Order

```{.prolog .program}
:- use_module(library(clpfd)).

% event_before(?Earlier, ?Later): a known ordering
% constraint between two events.
event_before(connect, query).
event_before(query, build).
event_before(connect, send).
event_before(send, reply).

% event_sequence_order(-Events, -Order): Order
% is a total order of Events consistent with
% every event_before/2 constraint.
event_sequence_order(Events, Order) :-
    setof(E,
          X^( event_before(E, X)
            ; event_before(X, E) ),
          Events),
    pairs_keys_values(Pairs, Events, Vars),
    length(Events, L),
    Vars ins 1..L,
    all_distinct(Vars),
    findall(A-B, event_before(A, B), Edges),
    post_order(Edges, Pairs),
    label(Vars),
    pairs_keys_values(KV, Vars, Events),
    keysort(KV, Sorted),
    pairs_values(Sorted, Order).

% post_order(+Edges, +Pairs): post VA #< VB for
% each edge A-B, where Pairs maps events to vars.
post_order([], _).
post_order([A-B|Edges], Pairs) :-
    memberchk(A-VA, Pairs),
    memberchk(B-VB, Pairs),
    VA #< VB,
    post_order(Edges, Pairs).
```

```{.prolog .query}
?- event_sequence_order(_Es, Order).
Order = [connect, query, build, send, reply] ;
Order = [connect, query, send, build, reply] ;
Order = [connect, send, query, build, reply] ;
...
```

## 28.2 Event Sequence Phase

```{.prolog .program}
% phase_boundaries(-Bs): the first message
% number of each phase after startup, in order.
phase_boundaries([B1, B2, B3, B4, B5]) :-
    aggregate_all(min(N), kind(N, received), B1),
    aggregate_all(min(N), kind(N, queued), B2),
    aggregate_all(min(N),
        ( text_of(N, T),
          sub_string(T, 0, _, _, "Housekeeping")
        ), B3),
    aggregate_all(min(N), msg(N, _, _, 109, _, _),
                  B4),
    aggregate_all(min(N),
        ( text_of(N, T),
          sub_string(T, 0, _, _,
                    "Service stopping")
        ), B5).

% message_phase(?N, -Phase): N's phase.
message_phase(N, Phase) :-
    phase_boundaries([B1, B2, B3, B4, B5]),
    msg(N, _, _, _, _, _),
    (   N >= B5 ->  Phase = shutdown
    ;   N >= B4 ->  Phase = failure
    ;   N >= B3 ->  Phase = drain
    ;   N >= B2 ->  Phase = saturation
    ;   N >= B1 ->  Phase = serving
    ;   Phase = startup
    ).

% phase_extent(?Phase, -Lo-Hi, -Count): the first
% and last message of Phase and how many it holds.
phase_extent(Phase, Lo-Hi, Count) :-
    distinct(Phase, message_phase(_, Phase)),
    findall(N, message_phase(N, Phase), Ns),
    min_list(Ns, Lo),
    max_list(Ns, Hi),
    length(Ns, Count).
```

```{.prolog .query}
?- phase_extent(Phase, Extent, Count).
Phase = startup,
Extent = 1-10,
Count = 10 ;
Phase = serving,
Extent = 11-37,
Count = 27 ;
Phase = saturation,
Extent = 38-47,
Count = 10 ;
Phase = drain,
Extent = 48-66,
Count = 19 ;
Phase = failure,
Extent = 67-70,
Count = 4 ;
Phase = shutdown,
Extent = 71-71,
Count = 1.
```

## 28.3 Macrofunction

```{.prolog .program}
% open_close(?Open, ?Close): Open begins and Close
% ends a bracketed activity.
open_close(dispatched, completed).
open_close(query_start, query_end).
open_close(build_start, build_end).

% ev(+N, ?Token): the bracket token of message N:
% open for a kind that begins a bracket, close for
% one that ends it, leaf for any other.
ev(N, Token) :-
    kind(N, K),
    (   open_close(K, _)
    ->  Token = open(K, N)
    ;   open_close(K0, K)
    ->  Token = close(K0, N)
    ;   Token = leaf(K, N)
    ).

% macrofunction(+TID, -Trees): the nesting forest
% of thread TID's activities.
macrofunction(TID, Trees) :-
    thread_sequence(TID, Ns),
    maplist(ev, Ns, Events),
    phrase(forest(Trees), Events).

forest([T|Ts]) --> tree(T), forest(Ts).
forest([]) --> [].

tree(node(K, N, Children)) -->
    [open(K, N)],
    forest(Children),
    [close(K, _)].
tree(leaf(K, N)) -->
    [leaf(K, N)].

% print_forest(+Trees, +Indent): print the forest
% with two spaces of indentation per level.
print_forest(Trees, Indent) :-
    forall(member(T, Trees),
           print_tree(T, Indent)).

print_tree(leaf(K, N), Indent) :-
    format("~*c~a ~d~n", [Indent, 0' , K, N]).
print_tree(node(K, N, Children), Indent) :-
    format("~*c~a ~d~n", [Indent, 0' , K, N]),
    Deeper is Indent + 2,
    print_forest(Children, Deeper).
```

```{.prolog .query}
?- once(macrofunction(101, _Trees)),
   print_forest(_Trees, 0).
other 7
dispatched 12
  query_start 13
  build_start 15
dispatched 53
  query_start 54
  build_start 56
dispatched 59
dispatched 61
dispatched 63
dispatched 65
true.
```

## 28.4 Motif

```{.prolog .program}
% window(+Len, +List, -Sub): Sub is a contiguous
% sub-sequence of List of length Len.
window(Len, List, Sub) :-
    length(Sub, Len),
    append(_, Rest, List),
    append(Sub, _, Rest).

% all_windows(+Len, -Windows): every length-Len
% window of every thread's kind sequence.
all_windows(Len, Windows) :-
    findall(Sub,
            ( trace_thread(TID),
              thread_kinds(TID, Kinds),
              window(Len, Kinds, Sub)
            ),
            Windows).

% motif(+Len, -Motif, -Count): Motif is a
% length-Len sequence of kinds occurring Count
% times, Count at least two.
motif(Len, Motif, Count) :-
    all_windows(Len, Windows),
    msort(Windows, Sorted),
    run_counts(Sorted, Counts),
    member(Motif-Count, Counts),
    Count >= 2.
```

```{.prolog .query}
?- findall(C-M, motif(3, M, C), _Pairs),
   sort(0, @>=, _Pairs, _Sorted),
   forall(member(C-M, _Sorted),
          format("~t~d~3| ~w~n", [C, M])).
  7 [other,other,other]
  4 [resize,resize,resize]
  4 [completed,dispatched,completed]
  3 [received,received,received]
  3 [query_start,query_end,build_start]
  3 [dispatched,query_start,query_end]
  3 [dispatched,completed,dispatched]
  2 [received,queued,received]
  2 [queued,received,queued]
  2 [query_end,build_start,build_end]
  2 [other,dispatched,query_start]
  2 [other,dispatched,other]
  2 [error,received,error]
  2 [dispatched,other,other]
  2 [build_start,build_end,completed]
  2 [build_end,completed,dispatched]
true.
```

## 28.5 Dominant Event Sequence

```{.prolog .program}
% trace_frame(+Size, ?Index, -Ns): the messages of
% the Index-th window of Size messages.
trace_frame(Size, Index, Ns) :-
    aggregate_all(max(N), msg(N, _, _, _, _, _),
                  Max),
    Frames is (Max + Size - 1) // Size,
    between(1, Frames, Index),
    Lo is (Index - 1) * Size + 1,
    Hi is Index * Size,
    findall(N,
            ( between(Lo, Hi, N),
              msg(N, _, _, _, _, _)
            ),
            Ns).

% modal_kind(+Ns, -Kind): the most frequent kind
% among the messages Ns.
modal_kind(Ns, Kind) :-
    findall(K, ( member(N, Ns), kind(N, K) ), Ks),
    msort(Ks, Sorted),
    run_counts(Sorted, Counts),
    sort(2, @>=, Counts, [Kind-_|_]).

% dominant_event_sequence(+Size, -Seq): the modal
% kind of each non-empty frame of Size messages.
dominant_event_sequence(Size, Seq) :-
    findall(K,
            ( trace_frame(Size, _, Ns),
              Ns \== [],
              modal_kind(Ns, K)
            ),
            Seq).
```

```{.prolog .query}
?- dominant_event_sequence(10, _Seq),
   print_kinds(_Seq).
  1 other
  2 dispatched
  3 other
  4 resize
  5 error
  6 completed
  7 completed
  8 other
true.

?- dominant_event_sequence(18, _Seq),
   print_kinds(_Seq).
  1 other
  2 resize
  3 other
  4 completed
true.
```

## 28.6 Inter-Correlation and Intra-Correlation

```{.prolog .program}
% intra_correlation(?K1, ?K2, -Count): kinds K1
% and K2, with K1 before K2 in standard order,
% occur together on Count threads, Count >= 2.
intra_correlation(K1, K2, Count) :-
    findall(A-B,
            ( trace_thread(TID),
              aggregate_all(set(K),
                  ( msg(N, _, _, TID, _, _),
                    kind(N, K) ),
                  Ks),
              member(A, Ks),
              member(B, Ks),
              A @< B
            ),
            Pairs),
    msort(Pairs, Sorted),
    run_counts(Sorted, Counts),
    member((K1-K2)-Count, Counts),
    Count >= 2.
```

```{.prolog .query}
?- findall(C-(K1-K2),
      intra_correlation(K1, K2, C), _Ps),
   sort(0, @>=, _Ps, _S),
   forall(limit(5, member(C-P, _S)),
          format("~t~d~3| ~w~n", [C, P])).
  4 dispatched-other
  2 query_end-query_start
  2 other-received
  2 other-query_start
  2 other-query_end
true.
```

## 28.7 Split Trace and Master Trace

```{.prolog .program}
:- multifile msg/7.

% trace a: the appserver log alone.
msg(a, 1, 0.000, 4120, 100, appserver,
    "Service starting, version 3.2.1.0").
msg(a, 2, 1.002, 4120, 100, appserver,
    "Request 1 received: GET /report/17").
msg(a, 3, 1.311, 4120, 101, appserver,
    "Request 1 completed: 200, 309 ms").
msg(a, 4, 14.010, 4120, 100, appserver,
    "Service stopping").

% trace b: the dbclient log, same run.
msg(b, 1, 0.115, 4120, 100, dbclient,
    "Connecting to db01:5432").
msg(b, 2, 0.312, 4120, 100, dbclient,
    "Connected to db01:5432, session=71").
msg(b, 3, 1.104, 4120, 101, dbclient,
    "Query start: SELECT report 17").
msg(b, 4, 14.102, 4120, 109, dbclient,
    "Error: copy failed, code=0x3e6").

% trace_source(?T): a split trace to be merged.
trace_source(a).
trace_source(b).

% master_trace(-Rows): the split traces merged
% into one time-ordered list of row/5 terms.
master_trace(Rows) :-
    findall(row(Time, T, N, TID, Text),
            ( trace_source(T),
              msg(T, N, Time, _, TID, _, Text)
            ),
            Rows0),
    predsort(by_time, Rows0, Rows).

% by_time(-Order, +Row1, +Row2): order rows by
% time, breaking ties by trace then number so
% that no two distinct rows compare equal.
by_time(Order, row(T1, Tr1, N1, _, _),
               row(T2, Tr2, N2, _, _)) :-
    (   compare(O0, T1, T2), O0 \== (=)
    ->  Order = O0
    ;   compare(O1, Tr1, Tr2), O1 \== (=)
    ->  Order = O1
    ;   compare(Order, N1, N2)
    ).

% print_master(+Rows): one line per merged row.
print_master(Rows) :-
    forall(member(row(Time, T, N, TID, Text),
                  Rows),
           format("~3f ~a~d ~d ~s~n",
                  [Time, T, N, TID, Text])).
```

```{.prolog .query}
?- master_trace(_Rows), print_master(_Rows).
0.000 a1 100 Service starting, version 3.2.1.0
0.115 b1 100 Connecting to db01:5432
0.312 b2 100 Connected to db01:5432, session=71
1.002 a2 100 Request 1 received: GET /report/17
1.104 b3 101 Query start: SELECT report 17
1.311 a3 101 Request 1 completed: 200, 309 ms
14.010 a4 100 Service stopping
14.102 b4 109 Error: copy failed, code=0x3e6
true.
```

## 28.8 Quotient Trace

```{.prolog .program}
% quotient_trace(-Classes): the message numbers
% grouped into Kind-Members classes.
quotient_trace(Classes) :-
    findall(K-N, kind(N, K), Pairs),
    keysort(Pairs, Sorted),
    group_pairs_by_key(Sorted, Classes).
```

```{.prolog .query}
?- quotient_trace(_Classes),
   forall(member(_K-_Ns, _Classes),
          ( length(_Ns, L),
            format("~a ~d~n", [_K, L]) )).
build_end 2
build_start 3
completed 6
dispatched 9
error 4
other 22
query_end 3
query_start 3
queued 3
received 10
resize 6
true.
```

## 28.9 Impossible Trace

```{.prolog .program}
% orderable(+Edges, -Order): Order is a total
% order of the events in Edges satisfying every
% edge; fails when the edges are contradictory.
orderable(Edges, Order) :-
    setof(E,
          X^( member(E-X, Edges)
            ; member(X-E, Edges) ),
          Events),
    pairs_keys_values(Pairs, Events, Vars),
    length(Events, L),
    Vars ins 1..L,
    all_distinct(Vars),
    post_order(Edges, Pairs),
    label(Vars),
    pairs_keys_values(KV, Vars, Events),
    keysort(KV, Sorted),
    pairs_values(Sorted, Order).
```

```{.prolog .query}
?- orderable([connect-query, query-send,
              send-reply], Order).
Order = [connect, query, send, reply].

?- orderable([connect-query, query-send,
              send-reply, reply-connect], Order).
false.
```

## 28.10 Data Reversal

```{.prolog .program}
:- multifile msg/7.

% a buffer-reordered excerpt: the reply was
% flushed before the send that caused it.
msg(rev, 1, 5.000, 4120, 120, dbclient,
    "Reply received: session=90, bytes=256").
msg(rev, 2, 5.001, 4120, 120, dbclient,
    "Send start: session=90, bytes=1024").

% session_token(+Text, -Tok): Text's session=
% token.
session_token(Text, Tok) :-
    split_string(Text, " ,", " ,", Words),
    member(Tok, Words),
    sub_string(Tok, 0, 8, _, "session=").

% data_reversal(+Trace, -Key, -Reply, -Send): in
% Trace a reply for Key on a thread precedes the
% send for Key on the same thread.
data_reversal(Trace, Key, Reply, Send) :-
    msg(Trace, Reply, _, _, TID, _, RText),
    sub_string(RText, 0, _, _, "Reply received"),
    session_token(RText, Key),
    msg(Trace, Send, _, _, TID, _, SText),
    sub_string(SText, 0, _, _, "Send start"),
    session_token(SText, Key),
    Reply < Send.
```

```{.prolog .query}
?- data_reversal(rev, Key, Reply, Send).
Key = "session=90",
Reply = 1,
Send = 2 ;
false.

?- data_reversal(rev, _, _, _).
true ;
false.
```

## 28.11 Dialogue

```{.prolog .program}
% keyed_message(?N, -TID, -Key): message N on
% thread TID bears the session Key.
keyed_message(N, TID, Key) :-
    msg(N, _, _, TID, _, Text),
    session_token(Text, Key).

% dialogue(?Key, -Turns): the turns of the
% dialogue on Key, as N-TID pairs in order, when
% at least two threads take part.
dialogue(Key, Turns) :-
    distinct(Key, keyed_message(_, _, Key)),
    aggregate_all(set(TID),
                  keyed_message(_, TID, Key),
                  TIDs),
    TIDs = [_, _|_],
    findall(N-TID, keyed_message(N, TID, Key),
            Turns0),
    sort(Turns0, Turns).
```

```{.prolog .query}
?- dialogue(Key, Turns).
Key = "session=71",
Turns = [5-100, 26-103, 29-104, 68-109] ;
false.

?- dialogue(Key, _Turns),
   pairs_values(_Turns, _TIDs),
   sort(_TIDs, Parties).
Key = "session=71",
Parties = [100, 103, 104, 109] ;
false.
```

## 28.12 Minimal Trace

```{.prolog .program}
% minimal_trace(-Ns): the first message of each
% kind, in message order.
minimal_trace(Ns) :-
    setof(K, N^kind(N, K), Kinds),
    foldl(first_of_kind, Kinds, [], Ns0),
    sort(Ns0, Ns).

% first_of_kind(+K, +Acc, -Acc1): add the first
% message of kind K to the accumulator.
first_of_kind(K, Acc, [N|Acc]) :-
    aggregate_all(min(M), kind(M, K), N).
```

```{.prolog .query}
?- minimal_trace(_Ns), print_messages(_Ns).
  1 100 Service starting, version 3.2.1.0
 11 100 Request 1 received: GET /report/17
 12 101 Request 1 dispatched to worker 101
 13 101 Query start: SELECT report 17
 14 101 Query end: 1 row, 44 ms
 15 101 Build start: report 17
 16 101 Build end: report 17, 2611 nodes, 261 ms
 17 101 Request 1 completed: 200, 309 ms
 31 102 Warning: table resize, 8192 -> 16384
 38 100 No idle worker, request 5 queued
 43 100 Error: queue depth 3 exceeds threshold 2
true.
```

## 28.13 Visitor Trace

```{.prolog .program}
% visitor_trace(?TID, -Components): the set of
% components thread TID wrote to, when it
% visited at least three.
visitor_trace(TID, Components) :-
    trace_thread(TID),
    aggregate_all(set(C),
                  msg(_, _, _, TID, C, _),
                  Components),
    length(Components, L),
    L >= 3.
```

```{.prolog .query}
?- visitor_trace(TID, Components).
TID = 100,
Components = [appserver, cachelib, dbclient] ;
TID = 101,
Components = [appserver, dbclient, reportengine] ;
TID = 102,
Components = [appserver, dbclient, reportengine] ;
false.
```

## 28.14 Semantic Mapping

```{.prolog .program}
% semantic(?Kind, ?Class): the meaning class of a
% message kind.
semantic(received, request_arrival).
semantic(dispatched, request_arrival).
semantic(completed, request_done).
semantic(query_start, db_io).
semantic(query_end, db_io).
semantic(build_start, cpu_work).
semantic(build_end, cpu_work).
semantic(resize, cpu_work).
semantic(queued, back_pressure).
semantic(error, fault).
semantic(other, other).

% mapped(?N, -Class): message N's semantic
% class.
mapped(N, Class) :-
    kind(N, Kind),
    semantic(Kind, Class).

% class_count(?Class, -Count): how many
% messages map to Class.
class_count(Class, Count) :-
    distinct(Class, semantic(_, Class)),
    aggregate_all(count, mapped(_, Class), Count).
```

```{.prolog .query}
?- class_count(Class, Count).
Class = request_arrival,
Count = 19 ;
Class = request_done,
Count = 6 ;
Class = db_io,
Count = 6 ;
Class = cpu_work,
Count = 11 ;
Class = back_pressure,
Count = 3 ;
Class = fault,
Count = 4 ;
Class = other,
Count = 22.
```

## 28.15 Karnaugh Map

```{.prolog .program}
% semantic_classes(-Classes): the semantic classes
% in standard order.
semantic_classes(Classes) :-
    setof(C, K^semantic(K, C), Classes).

% present(+TID, +Class, -Bit): 1 if thread TID
% has a message of Class, else 0.
present(TID, Class, Bit) :-
    (   once(( msg(N, _, _, TID, _, _),
               mapped(N, Class) ))
    ->  Bit = 1
    ;   Bit = 0
    ).

% karnaugh_map: print the thread-by-class grid,
% one row per thread, the bits in class order.
karnaugh_map :-
    semantic_classes(Classes),
    forall(trace_thread(TID),
           ( findall(Bit,
                     ( member(C, Classes),
                       present(TID, C, Bit) ),
                     Bits),
             atomic_list_concat(Bits, ' ', Row),
             format("~t~d~5|  ~w~n", [TID, Row])
           )).
```

```{.prolog .query}
?- semantic_classes(_Cs),
   forall(member(C, _Cs), writeln(C)).
back_pressure
cpu_work
db_io
fault
other
request_arrival
request_done
true.

?- karnaugh_map.
  100  1 0 0 1 1 1 0
  101  0 1 1 0 1 1 1
  102  0 1 1 0 1 1 0
  103  0 0 0 0 1 1 0
  104  0 0 0 0 1 1 0
  108  0 0 0 0 1 0 0
  109  0 0 0 1 1 1 0
true.
```

## 28.16 State Dump

```{.prolog .program}
% numbers_in(+Text, -Numbers): Text's numbers.
numbers_in(Text, Numbers) :-
    split_string(Text, " ,->", " ,->", Parts),
    convlist([P, V]>>number_string(V, P), Parts,
             Numbers).

% state_dump(?N, -Before, -After): message N
% dumps a table resize from Before to After.
state_dump(N, Before, After) :-
    kind(N, resize),
    text_of(N, Text),
    numbers_in(Text, [Before, After]).
```

```{.prolog .query}
?- state_dump(N, Before, After).
N = 31,
Before = 8192,
After = 16384 ;
N = 32,
Before = 16384,
After = 32768 ;
N = 33,
Before = 32768,
After = 65536 ;
...

?- findall(After, state_dump(_, _, After), _As),
   max_list(_As, Max).
Max = 524288.
```

## 28.17 Small DA+TA

```{.prolog .program}
:- [dump1].
```

```{.prolog .program}
% trace_exception(-TID, -Code): a thread
% reported an unhandled exception with Code.
trace_exception(TID, Code) :-
    msg(_, _, _, TID, _, Text),
    split_string(Text, " ,", " ,", Parts),
    member(P, Parts),
    sub_string(P, 0, 2, _, "0x"),
    number_string(Code, P),
    Code >= 0xc000_0000.

% exception_corroborated(-TID, -Code, -Address):
% the trace's exception on TID matches the
% dump's exception_record/3, giving the Address.
exception_corroborated(TID, Code, Address) :-
    trace_exception(TID, Code),
    exception_record(TID, Code, Address).
```

```{.prolog .query}
?- forall(exception_corroborated(T, C, A),
          format("thread ~d code ~16r at ~16r~n",
                 [T, C, A])).
thread 109 code c0000005 at 7ffb8d1031aa
true.
```

```{.prolog .program}
% housekeeping_wait(-TID, -Ms): the watchdog
% reported worker TID waiting Ms milliseconds.
housekeeping_wait(TID, Ms) :-
    msg(_, _, _, 108, _, Text),
    split_string(Text, " ", "", Words),
    nth1(3, Words, WTID),
    number_string(TID, WTID),
    nth1(5, Words, WMs),
    number_string(Ms, WMs).

% deadlock_corroborated(-TID, -Ms, -Addr): a
% worker the watchdog reported waiting is, in
% the dump, blocked on critical section Addr.
deadlock_corroborated(TID, Ms, Addr) :-
    housekeeping_wait(TID, Ms),
    waits_for(TID, critical_section, Addr).
```

```{.prolog .query}
?- forall(deadlock_corroborated(T, Ms, A),
          format("~d waited ~d ms on ~16r~n",
                 [T, Ms, A])).
103 waited 7001 ms on 7ff61d13a140
104 waited 6900 ms on 7ff61d13a0c0
true.
```

```{.prolog .program}
% spiking_corroborated(-TID, -Ms): a worker the
% watchdog reported at full CPU has high CPU time
% in the dump.
spiking_corroborated(TID, Ms) :-
    msg(_, _, _, 108, _, Text),
    sub_string(Text, _, _, _, "cpu 100%"),
    split_string(Text, " ", "", Words),
    nth1(3, Words, WTID),
    number_string(TID, WTID),
    thread_time(TID, User, Kernel),
    Ms is User + Kernel.
```

```{.prolog .query}
?- forall(spiking_corroborated(T, Ms),
          format("thread ~d: ~d ms~n", [T, Ms])).
thread 102: 9680 ms
true.
```

# Chapter 27. Messages

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/27-message-patterns.md`.

```{.prolog .program}
:- [trace1].

% print_messages(+Ns): print message N for each N
% in Ns, with its thread.
print_messages(Ns) :-
    forall(member(N, Ns), print_msg(N)).

print_msg(N) :-
    msg(N, _, _, TID, _, Text),
    format("~t~d~3| ~d ~s~n", [N, TID, Text]).

% text_of(?N, ?Text): the text of message N.
text_of(N, Text) :-
    msg(N, _, _, _, _, Text).

% trace_thread(-TID): TID is a thread of the
% trace; each thread once.
trace_thread(TID) :-
    distinct(TID, msg(_, _, _, TID, _, _)).

% thread_sequence(+TID, -Ns): the numbers of the
% messages of thread TID, in order.
thread_sequence(TID, Ns) :-
    findall(N, msg(N, _, _, TID, _, _), Ns0),
    sort(Ns0, Ns).
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.

?- print_messages([1, 70, 71]).
  1 100 Service starting, version 3.2.1.0
 70 109 Unhandled exception 0xc0000005, thread 109
 71 100 Service stopping
true.

?- thread_sequence(109, Ns).
Ns = [67, 68, 69, 70].
```

## 27.1 Error Message

```{.prolog .program}
% error_message(?N): message N is marked as an
% error by the component that wrote it.
error_message(N) :-
    text_of(N, Text),
    sub_string(Text, 0, _, _, "Error:").
```

```{.prolog .query}
?- findall(N, error_message(N), Ns).
Ns = [43, 45, 47, 69].

?- error_message(70).
false.

?- print_messages([43, 69]).
 43 100 Error: queue depth 3 exceeds threshold 2
 69 109 Error: buffer copy failed, code=0x3e6
true.
```

## 27.2 Significant Event

```{.prolog .program}
% significant_event(?N, ?Why): message N is
% significant for the reason Why.
significant_event(N, first_error) :-
    aggregate_all(min(E), error_message(E), N).
significant_event(N, exception) :-
    text_of(N, Text),
    sub_string(Text, _, _, _, "exception").
significant_event(N, lifecycle) :-
    text_of(N, Text),
    sub_string(Text, 0, _, _, "Service").
significant_event(N, saturation) :-
    text_of(N, Text),
    sub_string(Text, 0, _, _, "No idle worker").
```

```{.prolog .query}
?- forall(significant_event(N, Why),
          format("~t~d~3| ~a~n", [N, Why])).
 43 first_error
 70 exception
  1 lifecycle
 71 lifecycle
 38 saturation
 40 saturation
 42 saturation
true.

?- significant_event(N, first_error),
   print_messages([N]).
 43 100 Error: queue depth 3 exceeds threshold 2
N = 43.
```

## 27.3 Message Invariant

```{.prolog .program}
% invariant(+Text, -Inv): Inv is Text with every
% number replaced by #.
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

% skip_number(+Cs, -Rest): Rest is Cs without its
% leading letters, digits, and dots.
skip_number(Cs, Rest) :-
    (   Cs = [C|Cs1],
        (   code_type(C, alnum)
        ;   C == 0'.
        )
    ->  skip_number(Cs1, Rest)
    ;   Rest = Cs
    ).

% message_invariant(?N, ?Inv): Inv is the
% invariant of the text of message N.
message_invariant(N, Inv) :-
    text_of(N, Text),
    invariant(Text, Inv).

% prefix_of(+Prefix, ?N): the invariant of
% message N begins with Prefix.
prefix_of(Prefix, N) :-
    message_invariant(N, Inv),
    string_concat(Prefix, _, Inv).
```

```{.prolog .query}
?- message_invariant(16, Inv).
Inv = "Build end: report #, # nodes, # ms".

?- message_invariant(70, Inv).
Inv = "Unhandled exception #, thread #".

?- aggregate_all(count,
      distinct(I, message_invariant(_, I)), C).
C = 33.

?- forall(limit(5, order_by([desc(C), asc(I)],
      aggregate(count, N^message_invariant(N, I),
                C))),
      format("~t~d~3| ~s~n", [C, I])).
  9 Request # dispatched to worker #
  6 Request # completed: #, # ms
  6 Warning: table resize, # -> #
  4 Request # received: GET /health
  4 Worker # ready
true.
```

## 27.4 Counter Value

```{.prolog .program}
% numbers_in(+Text, -Numbers): the numbers in Text
% that number_string/2 accepts, in order.
numbers_in(Text, Numbers) :-
    split_string(Text, " ,:=%", " ,:=%", Parts),
    convlist([P, V]>>number_string(V, P), Parts,
             Numbers).

% counter_value(?Inv, ?I, -Series): Series is the
% list of N-Value pairs of the I-th number of the
% messages with invariant Inv; it has at least two
% elements and is not constant.
counter_value(Inv, I, Series) :-
    distinct(Inv, message_invariant(_, Inv)),
    findall(N-Vs,
            ( message_invariant(N, Inv),
              text_of(N, Text),
              numbers_in(Text, Vs)
            ),
            Rows),
    Rows = [_-Vs0|_],
    length(Vs0, K),
    between(1, K, I),
    findall(N-V,
            ( member(N-Vs, Rows),
              nth1(I, Vs, V)
            ),
            Series),
    Series = [_, _|_],
    pairs_values(Series, [V0|Values]),
    \+ maplist(==(V0), Values).

% increasing(+Values): each value exceeds the one
% before it.
increasing([_]).
increasing([A, B|Rest]) :-
    A < B,
    increasing([B|Rest]).

% print_series(+Series): one line per pair.
print_series(Series) :-
    forall(member(N-V, Series),
           format("~t~d~3| ~w~n", [N, V])).
```

```{.prolog .query}
?- message_invariant(43, _I),
   counter_value(_I, I, S).
I = 1,
S = [43-3, 45-4, 47-5] ;
false.

?- message_invariant(31, _I),
   counter_value(_I, 2, _S),
   pairs_values(_S, _Vs),
   increasing(_Vs),
   last(_Vs, Last).
Last = 524288 ;
false.

?- message_invariant(58, _I),
   counter_value(_I, 3, _S),
   print_series(_S).
 17 309
 58 4300
 60 3302
 62 2305
 64 1307
 66 309
true ;
false.
```

## 27.5 Linked Messages

```{.prolog .program}
% id_word(?Word): Word, lowercased, introduces an
% identifier in this application's messages.
id_word("request").
id_word("report").
id_word("worker").
id_word("thread").
id_word("session").

% message_key(?N, ?Key): Key is a name=value token
% of message N, or a Name-Number pair of adjacent
% words where Name is an id_word/1.
message_key(N, Key) :-
    text_of(N, Text),
    split_string(Text, " ,:", " ,:", Words),
    (   member(Key, Words),
        sub_string(Key, _, _, _, "=")
    ;   nextto(Name, Number, Words),
        number_string(_, Number),
        string_lower(Name, Lower),
        id_word(Lower),
        Key = Lower-Number
    ).

% linked_messages(?N1, ?N2, ?Key): messages N1 and
% N2, N1 before N2, share Key.
linked_messages(N1, N2, Key) :-
    message_key(N1, Key),
    message_key(N2, Key),
    N1 < N2.
```

```{.prolog .query}
?- message_key(12, Key).
Key = "request"-"1" ;
Key = "worker"-"101" ;
false.

?- linked_messages(26, N, Key).
N = 29,
Key = "session=71" ;
N = 68,
Key = "session=71" ;
false.

?- linked_messages(N, 26, Key).
N = 5,
Key = "session=71" ;
false.

?- print_messages([5, 26, 29, 68]).
  5 100 Connected to db01:5432, session=71
 26 103 Send start: session=71, bytes=1024
 29 104 Reply received: session=71, bytes=512
 68 109 Receive start: session=71
true.
```

## 27.6 Shared Point

```{.prolog .program}
% shared_point(?Key, -TIDs): Key occurs in
% messages of at least two threads, TIDs.
shared_point(Key, TIDs) :-
    distinct(Key, message_key(_, Key)),
    aggregate_all(set(TID),
                  ( message_key(N, Key),
                    msg(N, _, _, TID, _, _)
                  ),
                  TIDs),
    TIDs = [_, _|_].
```

```{.prolog .query}
?- shared_point(Key, TIDs), length(TIDs, L),
   L > 2.
Key = "session=71",
TIDs = [100, 103, 104, 109],
L = 4 ;
false.

?- shared_point("session"-"9", TIDs).
TIDs = [103, 104] ;
false.

?- aggregate_all(count, shared_point(_, _), C).
C = 15.
```

## 27.7 Opposition Messages

```{.prolog .program}
% opposition(?Open, ?Close, ?Scope): messages
% beginning with Open and Close bracket an
% activity; Scope is thread or a key word.
opposition("Query start", "Query end", thread).
opposition("Build start", "Build end", thread).
opposition("Service starting", "Service stopping",
           thread).
opposition("Send start", "Reply received",
           "session").
opposition("Request # received",
           "Request # completed", "request").
opposition("Request # dispatched",
           "Request # completed", "request").

% key_word(+Key, -Word): the name part of a key.
key_word(Name-_, Name).
key_word(Key, Name) :-
    string(Key),
    sub_string(Key, B, _, _, "="),
    sub_string(Key, 0, B, _, Name).

% in_scope(+Scope, +N1, +N2): N1 and N2 belong to
% the same activity under Scope.
in_scope(thread, N1, N2) :-
    msg(N1, _, _, TID, _, _),
    msg(N2, _, _, TID, _, _).
in_scope(Word, N1, N2) :-
    string(Word),
    once(( message_key(N1, Key),
           key_word(Key, Word),
           message_key(N2, Key) )).

% opposition_messages(?N1, ?N2): N2 is the closing
% message matching the opening message N1.
opposition_messages(N1, N2) :-
    opposition(Open, Close, Scope),
    prefix_of(Open, N1),
    prefix_of(Close, N2),
    N1 < N2,
    in_scope(Scope, N1, N2),
    \+ ( prefix_of(Open, N3), N1 < N3, N3 < N2,
         in_scope(Scope, N1, N3) ),
    \+ ( prefix_of(Close, N3), N1 < N3, N3 < N2,
         in_scope(Scope, N1, N3) ).

% unmatched_open(?N): N opens an activity that no
% message closes.
unmatched_open(N) :-
    opposition(Open, _, _),
    prefix_of(Open, N),
    \+ opposition_messages(N, _).
```

```{.prolog .query}
?- opposition_messages(13, N).
N = 14 ;
false.

?- opposition_messages(N, 17).
N = 11 ;
N = 12 ;
false.

?- opposition_messages(26, N).
N = 29 ;
false.

?- findall(N, unmatched_open(N), _Ns),
   sort(_Ns, Ns).
Ns = [18, 19, 22, 23, 24, 27, 28, 67].

?- print_messages([18, 22, 23, 27, 67]).
 18 100 Request 2 received: GET /report/18
 22 102 Build start: report 18
 23 100 Request 3 received: POST /session/commit
 27 100 Request 4 received: GET /session/9
 67 109 Request 10 received: GET /session/9/data
true.
```

## 27.8 Characteristic Message Block

```{.prolog .program}
% characteristic_block(?Name, ?Prefixes): the
% block Name is the sequence of message kinds
% Prefixes.
characteristic_block(report_request,
    [ "Request # dispatched", "Query start",
      "Query end", "Build start", "Build end",
      "Request # completed" ]).

% characteristic_message_block(?Name, ?TID, -Ns):
% the consecutive messages Ns of thread TID form
% an instance of the block Name.
characteristic_message_block(Name, TID, Ns) :-
    characteristic_block(Name, Prefixes),
    trace_thread(TID),
    thread_sequence(TID, Seq),
    append(_, Rest, Seq),
    append(Ns, _, Rest),
    maplist(prefix_of, Prefixes, Ns).
```

```{.prolog .query}
?- characteristic_message_block(report_request,
      TID, Ns).
TID = 101,
Ns = [12, 13, 14, 15, 16, 17] ;
TID = 101,
Ns = [53, 54, 55, 56, 57, 58] ;
false.

?- print_messages([53, 54, 55, 56, 57, 58]).
 53 101 Request 5 dispatched to worker 101
 54 101 Query start: SELECT report 19
 55 101 Query end: 1 row, 53 ms
 56 101 Build start: report 19
 57 101 Build end: report 19, 2402 nodes, 239 ms
 58 101 Request 5 completed: 200, 4300 ms
true.
```

## 27.9 Missing Message

```{.prolog .program}
% missing_message(?Name, ?TID, -Ns, -Expected):
% the messages Ns of thread TID match a proper
% prefix of the block Name, at least two messages
% long, and the block's next kind, Expected, does
% not follow.
missing_message(Name, TID, Ns, Expected) :-
    characteristic_block(Name, Prefixes),
    trace_thread(TID),
    thread_sequence(TID, Seq),
    append(_, Rest, Seq),
    matched_prefix(Prefixes, Rest, Ns, Missing),
    Ns = [_, _|_],
    Missing = [Expected|_].

% matched_prefix(+Prefixes, +Seq, -Ns, -Missing):
% Ns are the leading messages of Seq that match
% the leading Prefixes in order; Missing are the
% prefixes left unmatched.
matched_prefix([], _, [], []).
matched_prefix([P|Ps], Seq, Ns, Missing) :-
    (   Seq = [N|Seq1],
        prefix_of(P, N)
    ->  Ns = [N|Ns1],
        matched_prefix(Ps, Seq1, Ns1, Missing)
    ;   Ns = [],
        Missing = [P|Ps]
    ).
```

```{.prolog .query}
?- missing_message(report_request, TID, Ns, E).
TID = 102,
Ns = [19, 20, 21, 22],
E = "Build end" ;
false.

?- thread_sequence(102, Ns).
Ns = [8, 19, 20, 21, 22, 31, 32, 33, 34|...].
```

## 27.10 Ordinals in Messages

```{.prolog .program}
% ordinal_message(+Prefix, -Ordinals): Ordinals
% are the request numbers of the messages of kind
% Prefix, in trace order.
ordinal_message(Prefix, Ordinals) :-
    findall(O,
            ( prefix_of(Prefix, N),
              message_key(N, "request"-S),
              number_string(O, S)
            ),
            Ordinals).

% missing_ordinals(+Ordinals, -Missing): the
% numbers between the least and the greatest of
% Ordinals that do not occur in it.
missing_ordinals(Ordinals, Missing) :-
    min_list(Ordinals, Min),
    max_list(Ordinals, Max),
    numlist(Min, Max, All),
    subtract(All, Ordinals, Missing).
```

```{.prolog .query}
?- ordinal_message("Request # received", _Os),
   missing_ordinals(_Os, M),
   format("~w~n", [_Os]).
[1,2,3,4,5,6,7,8,9,10]
M = [].

?- ordinal_message("Request # dispatched", Os),
   missing_ordinals(Os, M).
Os = [1, 2, 3, 4, 5, 6, 7, 8, 9],
M = [].

?- ordinal_message("Request # completed", Os),
   missing_ordinals(Os, M).
Os = [1, 5, 6, 7, 8, 9],
M = [2, 3, 4].
```

## 27.11 Anchor Messages

```{.prolog .program}
% anchor_messages(-Ns): Ns are the anchors of the
% trace, the request arrivals.
anchor_messages(Ns) :-
    findall(N, prefix_of("Request # received", N),
            Ns).

% anchored(+Anchor, -Ns): the messages from Anchor
% up to, not including, the next anchor.
anchored(Anchor, Ns) :-
    anchor_messages(Anchors),
    memberchk(Anchor, Anchors),
    (   aggregate_all(min(A),
                      ( member(A, Anchors),
                        A > Anchor
                      ),
                      Next)
    ->  true
    ;   aggregate_all(max(N), text_of(N, _),
                      Last),
        Next is Last + 1
    ),
    End is Next - 1,
    numlist(Anchor, End, Ns).
```

```{.prolog .query}
?- anchor_messages(_As), format("~w~n", [_As]).
[11,18,23,27,37,39,41,44,46,67]
true.

?- anchored(37, Ns).
Ns = [37, 38].

?- anchored(67, Ns), print_messages(Ns).
 67 109 Request 10 received: GET /session/9/data
 68 109 Receive start: session=71
 69 109 Error: buffer copy failed, code=0x3e6
 70 109 Unhandled exception 0xc0000005, thread 109
 71 100 Service stopping
Ns = [67, 68, 69, 70, 71].
```

## 27.12 Pivot Message

```{.prolog .program}
% pivot_message(+N, ?By, -Ns): Ns are the messages
% that share with message N its thread, its
% component, or a key; By is thread, component,
% or key(Key).
pivot_message(N, thread, Ns) :-
    msg(N, _, _, TID, _, _),
    thread_sequence(TID, Ns).
pivot_message(N, component, Ns) :-
    msg(N, _, _, _, C, _),
    findall(M, msg(M, _, _, _, C, _), Ns).
pivot_message(N, key(Key), Ns) :-
    message_key(N, Key),
    findall(M, message_key(M, Key), Ns).
```

```{.prolog .query}
?- pivot_message(69, thread, Ns).
Ns = [67, 68, 69, 70] ;
false.

?- pivot_message(69, component, _Ns),
   length(_Ns, L).
L = 12 ;
false.

?- pivot_message(26, By, Ns), length(Ns, L).
By = thread,
Ns = [9, 24, 25, 26],
L = 4 ;
By = component,
Ns = [4, 5, 13, 14, 20, 21, 26, 29, 54|...],
L = 12 ;
By = key("session=71"),
Ns = [5, 26, 29, 68],
L = 4 ;
By = key("bytes=1024"),
Ns = [26],
L = 1 ;
false.
```

## 27.13 Message Context

```{.prolog .program}
% message_context(+N, +K, -Ns): the messages from
% N-K to N+K that exist.
message_context(N, K, Ns) :-
    Lo is N - K,
    Hi is N + K,
    findall(M,
            ( between(Lo, Hi, M),
              msg(M, _, _, _, _, _)
            ),
            Ns).

% thread_context(+N, +K, -Ns): the messages of the
% thread of N within K positions of N on that
% thread.
thread_context(N, K, Ns) :-
    msg(N, _, _, TID, _, _),
    thread_sequence(TID, Seq),
    once(nth0(I, Seq, N)),
    findall(M,
            ( nth0(J, Seq, M),
              abs(J - I) =< K
            ),
            Ns).
```

```{.prolog .query}
?- message_context(53, 1, Ns).
Ns = [52, 53, 54].

?- thread_context(53, 1, Ns).
Ns = [17, 53, 54].

?- message_context(53, 1, _A),
   thread_context(53, 1, _B),
   append(_A, _B, _C), sort(_C, Ns),
   print_messages(Ns).
 17 101 Request 1 completed: 200, 309 ms
 52 108 Housekeeping: worker 101 idle
 53 101 Request 5 dispatched to worker 101
 54 101 Query start: SELECT report 19
Ns = [17, 52, 53, 54].
```

## 27.14 Indirect Message

```{.prolog .program}
% indirect_message(?N, -About): message N was
% written by one thread about the thread About.
indirect_message(N, About) :-
    msg(N, _, _, TID, _, _),
    message_key(N, Word-Number),
    memberchk(Word, ["worker", "thread"]),
    number_string(About, Number),
    About =\= TID.
```

```{.prolog .query}
?- indirect_message(N, About).
N = 49,
About = 103 ;
N = 50,
About = 104 ;
N = 51,
About = 102 ;
N = 52,
About = 101 ;
false.

?- thread_sequence(103, Ns).
Ns = [9, 24, 25, 26].
```

## 27.15 Identification Messages

```{.prolog .program}
% identity_word(?Word): Word introduces
% identifying information in a message.
identity_word("version").
identity_word("configuration").
identity_word("Connecting to").
identity_word("capacity=").
identity_word("threads=").

% identification_messages(-Ns): the messages
% that contain an identity_word/1.
identification_messages(Ns) :-
    findall(N,
            ( text_of(N, Text),
              once(( identity_word(W),
                     sub_string(Text, _, _, _, W)
                  ))
            ),
            Ns).
```

```{.prolog .query}
?- identification_messages(Ns),
   print_messages(Ns).
  1 100 Service starting, version 3.2.1.0
  2 100 Loading configuration C:\App\app.cfg
  3 100 Cache initialized, capacity=4096
  4 100 Connecting to db01:5432
  6 100 Worker pool started, threads=4
Ns = [1, 2, 3, 4, 6].
```

## 27.16 Implementation Discourse

```{.prolog .program}
% implementation_word(?Word): Word belongs to the
% implementation level of the messages.
implementation_word("0x").
implementation_word("thread").
implementation_word("table").
implementation_word("buffer").
implementation_word("cpu").
implementation_word("pool").
implementation_word("Cache").

% implementation_discourse(?N): message N uses
% implementation vocabulary.
implementation_discourse(N) :-
    text_of(N, Text),
    once(( implementation_word(W),
           sub_string(Text, _, _, _, W) )).
```

```{.prolog .query}
?- aggregate_all(count,
                 implementation_discourse(_), C).
C = 11.

?- findall(N, implementation_discourse(N), _Ns),
   exclude([N]>>prefix_of("Warning", N), _Ns, Ns),
   print_messages(Ns).
  3 100 Cache initialized, capacity=4096
  6 100 Worker pool started, threads=4
 51 108 Housekeeping: worker 102 cpu 100%
 69 109 Error: buffer copy failed, code=0x3e6
 70 109 Unhandled exception 0xc0000005, thread 109
Ns = [3, 6, 51, 69, 70].
```

## 27.17 Hidden Error

```{.prolog .program}
% failure_word(?Word): Word reports a failure
% without the error marking.
failure_word("failed").
failure_word("exception").
failure_word("No idle").
failure_word("Unhandled").

% hidden_error(?N): message N is not marked as an
% error but reports one.
hidden_error(N) :-
    text_of(N, Text),
    \+ error_message(N),
    once(( failure_word(W),
           sub_string(Text, _, _, _, W) )).
```

```{.prolog .query}
?- findall(N, hidden_error(N), Ns),
   print_messages(Ns).
 38 100 No idle worker, request 5 queued
 40 100 No idle worker, request 6 queued
 42 100 No idle worker, request 7 queued
 70 109 Unhandled exception 0xc0000005, thread 109
Ns = [38, 40, 42, 70].
```

## 27.18 Silent Messages

```{.prolog .program}
% silent_messages(?Inv): Inv is the invariant of a
% start message whose kind has no other message
% kind with the same stem.
silent_messages(Inv) :-
    distinct(Inv, message_invariant(_, Inv)),
    sub_string(Inv, B, _, 0, " start"),
    sub_string(Inv, 0, B, _, Stem),
    \+ ( message_invariant(_, Other),
         Other \== Inv,
         sub_string(Other, 0, _, _, Stem)
       ).
```

```{.prolog .query}
?- silent_messages(Inv).
Inv = "Session # commit start" ;
Inv = "Session # lookup start" ;
false.

?- print_messages([25, 30]).
 25 103 Session 9 commit start
 30 104 Session 9 lookup start
true.
```

## 27.19 Exception Stack Trace

```{.prolog .program}
:- multifile msg/6.

msg(72, 14.011, 4120, 109, appserver,
    "Stack trace for thread 109:").
msg(73, 14.011, 4120, 109, appserver,
    "  00 dbclient!Buffer::Copy+0x1a").
msg(74, 14.012, 4120, 109, appserver,
    "  01 dbclient!Connection::Receive+0x8c").
msg(75, 14.012, 4120, 109, appserver,
    "  02 appserver!Session::Fetch+0x44").
msg(76, 14.013, 4120, 109, appserver,
    "  03 appserver!Worker::Run+0x120").
msg(77, 14.013, 4120, 109, appserver,
    "  04 ucrtbase!thread_start<...>+0x42").
msg(78, 14.014, 4120, 109, appserver,
    "  05 kernel32!BaseThreadInitThunk+0x14").
msg(79, 14.014, 4120, 109, appserver,
    "  06 ntdll!RtlUserThreadStart+0x21").
```

```{.prolog .program}
:- use_module(library(dcg/basics)).

% frame_line(-Frame)//: parse a stack frame line
% into frame(N, Module, Function, Offset).
frame_line(frame(N, Module, Function, Offset)) -->
    blanks, integer(N), blank, blanks,
    string_without("!", MCodes), "!",
    string_without("+", FCodes), "+0x",
    xinteger(Offset), eos,
    { atom_codes(Module, MCodes),
      atom_codes(Function, FCodes) }.

% frame_message(?N, -Frame): message N is a frame
% line.
frame_message(N, Frame) :-
    text_of(N, Text),
    string_codes(Text, Codes),
    phrase(frame_line(Frame), Codes).

% exception_stack_trace(?TID, -Ns, -Frames): the
% frame messages Ns of thread TID parse to Frames.
exception_stack_trace(TID, Ns, Frames) :-
    trace_thread(TID),
    findall(N,
            ( msg(N, _, _, TID, _, _),
              frame_message(N, _)
            ),
            Ns),
    Ns = [_|_],
    maplist(frame_message, Ns, Frames).

% print_frames(+Frames): one line per frame, as a
% debugger would print it.
print_frames(Frames) :-
    forall(member(frame(N, M, F, O), Frames),
           format("~t~d~2| ~a!~a+0x~16r~n",
                  [N, M, F, O])).
```

```{.prolog .query}
?- frame_message(73, F).
F = frame(0, dbclient, 'Buffer::Copy', 26).

?- frame_message(72, F).
false.

?- exception_stack_trace(TID, Ns, _Frames),
   print_frames(_Frames).
 0 dbclient!Buffer::Copy+0x1a
 1 dbclient!Connection::Receive+0x8c
 2 appserver!Session::Fetch+0x44
 3 appserver!Worker::Run+0x120
 4 ucrtbase!thread_start<...>+0x42
 5 kernel32!BaseThreadInitThunk+0x14
 6 ntdll!RtlUserThreadStart+0x21
TID = 109,
Ns = [73, 74, 75, 76, 77, 78, 79] ;
false.
```

## 27.20 Message Change

```{.prolog .program}
:- multifile msg/7.

msg(t2, 1, 0.000, 4120, 100, tracer,
    "Trace session started, buffer 64 MB").
msg(t2, 2, 0.001, 4120, 100, appserver,
    "Service starting, version 3.3.0.0").
msg(t2, 3, 0.005, 4120, 100, appserver,
    "Loading configuration C:\\App\\app.cfg").
msg(t2, 4, 0.006, 4120, 100, appserver,
    "Error: key proxy missing, default used").
msg(t2, 5, 0.012, 4120, 100, cachelib,
    "Cache initialized, capacity=4096").
msg(t2, 6, 0.016, 4120, 100, dbclient,
    "Connecting to db01:5432").
msg(t2, 7, 0.230, 4120, 100, dbclient,
    "Connected to db01:5432, session=72").
msg(t2, 8, 0.231, 4120, 100, appserver,
    "Worker pool started, threads=4").
msg(t2, 9, 0.900, 4120, 100, tester,
    "MARK: step 1 begin").
msg(t2, 10, 1.002, 4120, 100, appserver,
    "Request 1 accepted: GET /report/17").
msg(t2, 11, 1.003, 4120, 101, appserver,
    "Request 1 dispatched to worker 101").
msg(t2, 12, 1.300, 4120, 101, appserver,
    "Request 1 completed: status=200, 297 ms").
msg(t2, 13, 1.400, 4120, 100, tester,
    "MARK: step 1 end").
msg(t2, 14, 1.500, 4120, 100, appserver,
    "Service stoppinged to worker 101").
msg(t2, 15, 1.501, 4120, 100, tracer,
    "Trace session stopped, events lost: 0").

% trace_text(?Trace, ?N, ?TID, ?Component, ?Text):
% a view over trace1 (msg/6) and the in-chapter
% traces (msg/7).
trace_text(trace1, N, TID, C, Text) :-
    msg(N, _, _, TID, C, Text).
trace_text(T, N, TID, C, Text) :-
    msg(T, N, _, _, TID, C, Text).

% trace_invariant(+Trace, ?Inv): Inv is an
% invariant of Trace; each once.
trace_invariant(T, Inv) :-
    distinct(Inv, ( trace_text(T, _, _, _, Text),
                    invariant(Text, Inv) )).

% similarity(+S1, +S2, -Sim): the share of words
% the two strings have in common.
similarity(S1, S2, Sim) :-
    split_string(S1, " ", ",:", W1),
    split_string(S2, " ", ",:", W2),
    intersection(W1, W2, Shared),
    length(Shared, N),
    length(W1, L1),
    length(W2, L2),
    Sim is N / max(L1, L2).

% message_change(+Old, +New, -OldInv, -NewInv):
% NewInv occurs in New only, and OldInv is the
% invariant of Old only that is most similar to
% it, at least half its words.
message_change(Old, New, OldInv, NewInv) :-
    trace_invariant(New, NewInv),
    \+ trace_invariant(Old, NewInv),
    aggregate_all(max(S, I),
                  ( trace_invariant(Old, I),
                    \+ trace_invariant(New, I),
                    similarity(NewInv, I, S)
                  ),
                  max(S, OldInv)),
    S >= 0.5.
```

```{.prolog .query}
?- message_change(trace1, t2, Old, New).
Old = "Request # received: GET /report/#",
New = "Request # accepted: GET /report/#" ;
Old = "Request # completed: #, # ms",
New = "Request # completed: status=#, # ms" ;
false.
```

## 27.21 False Positive Error

```{.prolog .program}
% benign_error(?Inv): messages with the invariant
% Inv are marked as errors but are routine.
benign_error(
    "Error: key proxy missing, default used").

% false_positive_error(+Trace, ?N): message N of
% Trace is marked as an error and is benign.
false_positive_error(T, N) :-
    trace_text(T, N, _, _, Text),
    sub_string(Text, 0, _, _, "Error:"),
    invariant(Text, Inv),
    benign_error(Inv).
```

```{.prolog .query}
?- false_positive_error(trace1, N).
false.

?- false_positive_error(t2, N),
   trace_text(t2, N, _, _, Text).
N = 4,
Text = "Error: key proxy missing, default used" ;
false.
```

## 27.22 Diegetic Messages

```{.prolog .program}
% non_diegetic_component(?C): component C writes
% about the trace, not from within the software.
non_diegetic_component(tracer).
non_diegetic_component(tester).

% diegetic_messages(+Trace, -Ns): the messages of
% Trace written by the software itself.
diegetic_messages(T, Ns) :-
    findall(N,
            ( trace_text(T, N, _, C, _),
              \+ non_diegetic_component(C)
            ),
            Ns).
```

```{.prolog .query}
?- diegetic_messages(t2, _Ns), length(_Ns, L),
   format("~w~n", [_Ns]).
[2,3,4,5,6,7,8,10,11,12,14]
L = 11.

?- forall(( trace_text(t2, N, _, C, Text),
            non_diegetic_component(C) ),
          format("~t~d~3| ~a ~s~n",
                 [N, C, Text])).
  1 tracer Trace session started, buffer 64 MB
  9 tester MARK: step 1 begin
 13 tester MARK: step 1 end
 15 tracer Trace session stopped, events lost: 0
true.

?- diegetic_messages(trace1, _Ns), length(_Ns, L).
L = 79.
```

## 27.23 Marked Message

```{.prolog .program}
% marked_message(+Trace, ?N, -Label): message N of
% Trace is a mark with the given Label.
marked_message(T, N, Label) :-
    trace_text(T, N, _, _, Text),
    string_concat("MARK: ", Label, Text).

% between_marks(+Trace, +Step, -Ns): the messages
% between the begin and end marks of Step.
between_marks(T, Step, Ns) :-
    marked_message(T, N1, L1),
    string_concat(Step, " begin", L1),
    marked_message(T, N2, L2),
    string_concat(Step, " end", L2),
    findall(N,
            ( trace_text(T, N, _, _, _),
              N1 < N, N < N2
            ),
            Ns).
```

```{.prolog .query}
?- marked_message(t2, N, Label).
N = 9,
Label = "step 1 begin" ;
N = 13,
Label = "step 1 end" ;
false.

?- between_marks(t2, "step 1", Ns).
Ns = [10, 11, 12] ;
false.

?- marked_message(trace1, N, Label).
false.
```

## 27.24 Palimpsest Messages

```{.prolog .program}
% palimpsest_messages(+Trace, ?N, -Over, -Under):
% the invariant of message N of Trace is the known
% invariant Over followed by a tail of the known
% invariant Under.
palimpsest_messages(T, N, Over, Under) :-
    trace_text(T, N, _, _, Text),
    invariant(Text, Inv),
    \+ trace_invariant(trace1, Inv),
    trace_invariant(trace1, Over),
    string_concat(Over, Tail, Inv),
    Tail \== "",
    trace_invariant(trace1, Under),
    Under \== Over,
    string_concat(_, Tail, Under).
```

```{.prolog .query}
?- palimpsest_messages(t2, N, Over, Under).
N = 14,
Over = "Service stopping",
Under = "Request # dispatched to worker #" ;
false.

?- trace_text(t2, 14, _, _, Text).
Text = "Service stoppinged to worker 101".
```

## 27.25 Translated Message

```{.prolog .program}
:- multifile msg/7.

msg(de, 1, 0.000, 4120, 100, appserver,
    "Dienst startet, Version 3.2.1.0").
msg(de, 2, 1.002, 4120, 100, appserver,
    "Anforderung 1 empfangen: GET /report/17").
msg(de, 3, 1.311, 4120, 101, appserver,
    "Anforderung 1 abgeschlossen: 200, 309 ms").
msg(de, 4, 14.002, 4120, 109, dbclient,
    "Fehler: Kopie fehlgeschlagen, Code=0x3e6").
msg(de, 5, 14.010, 4120, 100, appserver,
    "Dienst wird beendet").

% translation(?Foreign, ?English): the invariant
% Foreign is the localized form of English.
translation(
    "Dienst startet, Version #",
    "Service starting, version #").
translation(
    "Anforderung # empfangen: GET /report/#",
    "Request # received: GET /report/#").
translation(
    "Anforderung # abgeschlossen: #, # ms",
    "Request # completed: #, # ms").
translation(
    "Fehler: Kopie fehlgeschlagen, Code=#",
    "Error: buffer copy failed, code=#").
translation(
    "Dienst wird beendet",
    "Service stopping").

% digit_tokens(+Text, -Tokens): the runs of Text
% that invariant/2 blanks, as strings, in order.
digit_tokens(Text, Tokens) :-
    string_codes(Text, Codes),
    digit_runs(Codes, Tokens).

digit_runs([], []).
digit_runs([C|Cs], Tokens) :-
    (   code_type(C, digit)
    ->  take_run([C|Cs], Run, Rest),
        string_codes(Token, Run),
        Tokens = [Token|Tokens1],
        digit_runs(Rest, Tokens1)
    ;   digit_runs(Cs, Tokens)
    ).

take_run(Cs, Run, Rest) :-
    (   Cs = [C|Cs1],
        (   code_type(C, alnum)
        ;   C == 0'.
        )
    ->  Run = [C|Run1],
        take_run(Cs1, Run1, Rest)
    ;   Run = [],
        Rest = Cs
    ).

% fill(+Inv, +Tokens, -Text): Text is Inv with
% each # replaced by the next of Tokens.
fill(Inv, Tokens, Text) :-
    string_codes(Inv, Codes),
    fill_codes(Codes, Tokens, Out),
    string_codes(Text, Out).

fill_codes([], [], []).
fill_codes([C|Cs], Tokens, Out) :-
    (   C == 0'#
    ->  Tokens = [Token|Tokens1],
        string_codes(Token, TCodes),
        append(TCodes, Out1, Out),
        fill_codes(Cs, Tokens1, Out1)
    ;   Out = [C|Out1],
        fill_codes(Cs, Tokens, Out1)
    ).

% translated_message(+Trace, ?N, -English):
% message N of Trace, translated back by its
% invariant.
translated_message(T, N, English) :-
    trace_text(T, N, _, _, Text),
    invariant(Text, Foreign),
    translation(Foreign, EnglishInv),
    digit_tokens(Text, Tokens),
    fill(EnglishInv, Tokens, English).
```

```{.prolog .query}
?- translated_message(de, 4, E).
E = "Error: buffer copy failed, code=0x3e6".

?- forall(translated_message(de, N, E),
          format("~t~d~3| ~s~n", [N, E])).
  1 Service starting, version 3.2.1.0
  2 Request 1 received: GET /report/17
  3 Request 1 completed: 200, 309 ms
  4 Error: buffer copy failed, code=0x3e6
  5 Service stopping
true.

?- translated_message(de, 4, _E),
   invariant(_E, Inv),
   message_invariant(N, Inv).
Inv = "Error: buffer copy failed, code=#",
N = 69 ;
false.
```

## 27.26 Recovered Messages

```{.prolog .program}
% recovered(?Id, ?Text): a record recovered from
% the tracing buffer in the memory dump.
recovered(1, "ispatched to worker 102").
recovered(2, "Query start: SELECT report 18").
recovered(3,
    "Warning: table resize, 524288 -> 1048576").

% recovered_messages(?Id, -Inv): the recovered
% record Id ends like the trace invariant Inv.
recovered_messages(Id, Inv) :-
    recovered(Id, Text),
    invariant(Text, Fragment),
    distinct(Inv, message_invariant(_, Inv)),
    sub_string(Inv, _, _, 0, Fragment).
```

```{.prolog .query}
?- recovered_messages(Id, Inv).
Id = 1,
Inv = "Request # dispatched to worker #" ;
Id = 2,
Inv = "Query start: SELECT report #" ;
Id = 3,
Inv = "Warning: table resize, # -> #" ;
false.

?- recovered(3, Text), numbers_in(Text, Ns).
Text = "Warning: table resize, 524288 -> 1048576",
Ns = [524288, 1048576].
```

## 27.27 Message Annotations

```{.prolog .program}
:- dynamic message_annotation/2.

% annotate(+N, +Note): attach Note to message N.
annotate(N, Note) :-
    assertz(message_annotation(N, Note)).

% print_annotated(+Ns): print each message with
% its annotations indented below it.
print_annotated(Ns) :-
    forall(member(N, Ns),
           ( print_msg(N),
             forall(message_annotation(N, Note),
                    format("~t~8|> ~s~n", [Note]))
           )).
```

```{.prolog .query}
?- annotate(43, "first symptom; cause is 38"),
   annotate(70, "matches exception_record/3"),
   annotate(70, "0xc0000005: access violation").
true.

?- print_annotated([43, 70]).
 43 100 Error: queue depth 3 exceeds threshold 2
        > first symptom; cause is 38
 70 109 Unhandled exception 0xc0000005, thread 109
        > matches exception_record/3
        > 0xc0000005: access violation
true.

?- aggregate_all(count, message_annotation(_, _),
                 C).
C = 3.
```

## 27.28 Message Cover

```{.prolog .program}
% message_set(?Name, ?N): message N belongs to the
% named set.
message_set(lifecycle, N) :-
    prefix_of("Service", N).
message_set(identity, N) :-
    identification_messages(Ns),
    member(N, Ns).
message_set(workers, N) :-
    prefix_of("Worker", N).
message_set(request, N) :-
    message_key(N, "request"-_).
message_set(session, N) :-
    message_key(N, Key),
    key_word(Key, "session").
message_set(query, N) :-
    prefix_of("Query", N).
message_set(build, N) :-
    prefix_of("Build", N).
message_set(resize, N) :-
    prefix_of("Warning: table resize", N).
message_set(housekeeping, N) :-
    prefix_of("Housekeeping", N).
message_set(error, N) :-
    error_message(N).
message_set(error, N) :-
    hidden_error(N).
message_set(frames, N) :-
    frame_message(N, _).

% message_cover(+Names, -Uncovered): Uncovered are
% the messages that belong to none of the named
% sets.
message_cover(Names, Uncovered) :-
    findall(N,
            ( msg(N, _, _, _, _, _),
              \+ ( member(S, Names),
                   message_set(S, N) )
            ),
            Uncovered).
```

```{.prolog .query}
?- message_cover([request, error], _U),
   length(_U, L).
L = 46.

?- message_cover([lifecycle, identity, workers,
      request, session, resize, housekeeping,
      error], _U), length(_U, L).
L = 19.

?- message_cover([lifecycle, identity, workers,
      request, session, query, build, resize,
      housekeeping, error], U).
U = [72, 73, 74, 75, 76, 77, 78, 79].

?- message_cover([lifecycle, identity, workers,
      request, session, query, build, resize,
      housekeeping, error, frames], U).
U = [72].
```

## 27.29 Defamiliarizing Effect

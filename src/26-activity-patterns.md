# Chapter 26. Activities and Threads of Activity

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/26-activity-patterns.md`.

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

time_ms(N, Ms) :-
    msg(N, Time, _, _, _, _),
    Ms is round(Time * 1000).

% threshold(Name, Value): the thresholds of this
% chapter.
threshold(coupling, 10).
threshold(resume, 1000).
threshold(background, 0.75).
threshold(host_size, 3).
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.
```

## 26.1 Thread of Activity

```{.prolog .program}
% thread_of_activity(TID, Set): Set is the message
% set of thread TID; with TID unbound, one answer
% per thread.
thread_of_activity(TID, Set) :-
    bagof(N, T^P^C^X^msg(N, T, P, TID, C, X), Ns),
    sort(Ns, Set).
```

```{.prolog .query}
?- thread_of_activity(103, _S),
   print_messages(_S).
 9  0.216 103 appserver    Worker 103 ready
24  2.001 103 appserver    Request 3 dispatched to
25  2.002 103 appserver    Session 9 commit start
26  2.003 103 dbclient     Send start: session=71,
true.

?- thread_of_activity(T, _S), length(_S, L).
T = 100,
L = 22 ;
T = 101,
L = 21 ;
T = 102,
L = 11 ;
T = 103,
L = 4 ;
T = 104,
L = 4 ;
T = 108,
L = 5 ;
T = 109,
L = 4.
```

## 26.2 Adjoint Thread of Activity

```{.prolog .program}
% request_id(N, Request): the text of message N
% mentions request number Request.
request_id(N, Request) :-
    msg(N, _, _, _, _, Text),
    string_lower(Text, Lower),
    string_codes(Lower, Codes),
    phrase(request_mention(Request), Codes).

request_mention(Request) -->
    (   "request "
    ->  integer(Found),
        remainder(_),
        { Request = Found }
    ;   [_],
        request_mention(Request)
    ).

% adjoint(Key, N): message N belongs to the
% adjoint thread selected by Key.
adjoint(component(C), N) :-
    msg(N, _, _, _, C, _).
adjoint(request(R), N) :-
    request_id(N, R).

% adjoint_thread_of_activity(Key, Set): Set is the
% message set of the adjoint thread Key.
adjoint_thread_of_activity(Key, Set) :-
    bagof(N, adjoint(Key, N), Ns),
    sort(Ns, Set).
```

```{.prolog .query}
?- request_id(38, R).
R = 5.

?- request_id(67, 1).
false.

?- adjoint_thread_of_activity(request(5), _S),
   print_messages(_S).
37  5.001 100 appserver    Request 5 received: GET
38  5.002 100 appserver    No idle worker, request
53  9.006 101 appserver    Request 5 dispatched to
58  9.301 101 appserver    Request 5 completed: 20
true.

?- adjoint_thread_of_activity(component(C), _S),
   length(_S, L).
C = appserver,
L = 47 ;
C = cachelib,
L = 1 ;
C = dbclient,
L = 12 ;
C = reportengine,
L = 11.
```

## 26.3 Activity Region

```{.prolog .program}
% activity_region(Set, From, To): the messages of
% Set were written between From and To seconds.
activity_region(Set, From, To) :-
    Set = [First | _],
    last(Set, Last),
    msg(First, From, _, _, _, _),
    msg(Last, To, _, _, _, _).
```

```{.prolog .query}
?- thread_of_activity(103, _S),
   activity_region(_S, From, To).
From = 0.216,
To = 2.003.

?- adjoint_thread_of_activity(request(5), _S),
   activity_region(_S, From, To).
From = 5.001,
To = 9.301.
```

## 26.4 Activity Theatre

```{.prolog .program}
% window_messages(From, To, Set): the messages
% with From =< Time < To, in seconds.
window_messages(From, To, Set) :-
    findall(N,
            ( msg(N, T, _, _, _, _),
              T >= From, T < To ),
            Ns),
    sort(Ns, Set).

% activity_theatre(From, To, Actors): Actors is
% the list of TID-Count pairs of the threads with
% messages in the interval.
activity_theatre(From, To, Actors) :-
    window_messages(From, To, Set),
    findall(TID-N,
            ( member(N, Set),
              msg(N, _, _, TID, _, _) ),
            Pairs),
    keysort(Pairs, Sorted),
    group_pairs_by_key(Sorted, Groups),
    maplist(count_group, Groups, Actors).

count_group(Key-Ns, Key-Count) :-
    length(Ns, Count).
```

```{.prolog .query}
?- activity_theatre(2.0, 2.2, Actors).
Actors = [100-2, 103-3, 104-3].

?- activity_theatre(9.0, 9.4, Actors).
Actors = [100-2, 101-14, 108-5].

?- activity_theatre(3.0, 5.0, Actors).
Actors = [102-4].
```

## 26.5 Activity Overlap

```{.prolog .program}
% activity_overlap(SetA, SetB, From, To): the
% regions of the message sets SetA and SetB share
% the interval From..To.
activity_overlap(SetA, SetB, From, To) :-
    activity_region(SetA, FromA, ToA),
    activity_region(SetB, FromB, ToB),
    From is max(FromA, FromB),
    To is min(ToA, ToB),
    From < To.
```

```{.prolog .query}
?- adjoint_thread_of_activity(request(5), _A),
   adjoint_thread_of_activity(request(6), _B),
   activity_overlap(_A, _B, From, To).
From = 6.0,
To = 9.301.

?- adjoint_thread_of_activity(request(1), _A),
   adjoint_thread_of_activity(request(2), _B),
   activity_overlap(_A, _B, From, To).
false.

?- adjoint_thread_of_activity(request(RA), _A),
   adjoint_thread_of_activity(request(RB), _B),
   RA < RB, activity_overlap(_A, _B, _, _),
   RA =< 6.
RA = 5,
RB = 6 ;
RA = 5,
RB = 7 ;
RA = 5,
RB = 8 ;
RA = 5,
RB = 9 ;
RA = 6,
RB = 7 ;
RA = 6,
RB = 8 ;
RA = 6,
RB = 9 ;
false.
```

## 26.6 Fiber of Activity

```{.prolog .program}
% fiber_of_activity(TID, Key, Fiber): Fiber is the
% non-empty intersection of thread TID's activity
% with the adjoint thread Key.
fiber_of_activity(TID, Key, Fiber) :-
    thread_of_activity(TID, Thread),
    adjoint_thread_of_activity(Key, Adjoint),
    ord_intersection(Thread, Adjoint, Fiber),
    Fiber \== [].
```

```{.prolog .query}
?- fiber_of_activity(101, component(dbclient), F).
F = [13, 14, 54, 55].

?- fiber_of_activity(101, request(1), F).
F = [12, 17].

?- fiber_of_activity(T, request(5), F).
T = 100,
F = [37, 38] ;
T = 101,
F = [53, 58] ;
false.
```

## 26.7 Fiber Bundle

```{.prolog .program}
% fiber_bundle(Key, Bundle): Bundle is the list of
% TID-Fiber pairs of the adjoint thread Key.
fiber_bundle(Key, Bundle) :-
    findall(TID-Fiber,
            fiber_of_activity(TID, Key, Fiber),
            Bundle).

% print_bundle(Bundle): one line per fiber.
print_bundle(Bundle) :-
    forall(member(TID-Fiber, Bundle),
           format("~d~t~6|~w~n", [TID, Fiber])).
```

```{.prolog .query}
?- fiber_bundle(component(dbclient), _B),
   print_bundle(_B).
100   [4,5]
101   [13,14,54,55]
102   [20,21]
103   [26]
104   [29]
109   [68,69]
true.

?- fiber_bundle(request(5), _B), print_bundle(_B).
100   [37,38]
101   [53,58]
true.
```

## 26.8 Sheaf of Activities

```{.prolog .program}
% sheaf_of_activities(From, To, Sections):
% Sections is the list of TID-Set pairs of the
% threads with messages in From..To.
sheaf_of_activities(From, To, Sections) :-
    window_messages(From, To, Set),
    findall(TID-N,
            ( member(N, Set),
              msg(N, _, _, TID, _, _) ),
            Pairs),
    keysort(Pairs, Sorted),
    group_pairs_by_key(Sorted, Sections).

% restriction(Sections, From, To, Restricted): the
% sections cut down to the interval From..To.
restriction(Sections, From, To, Restricted) :-
    window_messages(From, To, Window),
    findall(TID-Part,
            ( member(TID-Ns, Sections),
              ord_intersection(Ns, Window, Part),
              Part \== [] ),
            Restricted).
```

```{.prolog .query}
?- sheaf_of_activities(2.0, 2.1, S).
S = [100-[23], 103-[24, 25, 26]].

?- sheaf_of_activities(1.0, 2.2, _Large),
   restriction(_Large, 2.0, 2.1, R).
R = [100-[23], 103-[24, 25, 26]].

?- sheaf_of_activities(1.0, 2.2, _Large),
   sheaf_of_activities(2.0, 2.1, S),
   restriction(_Large, 2.0, 2.1, S).
S = [100-[23], 103-[24, 25, 26]].
```

## 26.9 Coupled Activities

```{.prolog .program}
% coupled_activities(T1, T2, N1-N2): message N2 of
% thread T2 follows message N1 of thread T1 within
% the coupling threshold.
coupled_activities(T1, T2, N1-N2) :-
    msg(N1, Time1, _, T1, _, _),
    N2 is N1 + 1,
    msg(N2, Time2, _, T2, _, _),
    T1 \== T2,
    threshold(coupling, Max),
    round((Time2 - Time1) * 1000) =< Max.

% print_couplings: one line per hand-off.
print_couplings :-
    forall(coupled_activities(T1, T2, N1-N2),
           print_coupling(T1, T2, N1, N2)).

print_coupling(T1, T2, N1, N2) :-
    format("~t~d~3| -> ~d~t~12|~t~d~16|-~d~n",
           [T1, T2, N1, N2]).
```

```{.prolog .query}
?- print_couplings.
100 -> 101     6-7
101 -> 102     7-8
102 -> 103     8-9
103 -> 104     9-10
100 -> 101    11-12
100 -> 102    18-19
100 -> 103    23-24
100 -> 104    27-28
102 -> 100    36-37
100 -> 108    47-48
108 -> 101    52-53
109 -> 100    70-71
true.

?- aggregate_all(count,
   coupled_activities(100, _, _), N).
N = 6.
```

## 26.10 Glued Activity

```{.prolog .program}
% boundary(N): message N begins a new piece of
% work on its thread.
boundary(N) :-
    msg(N, _, _, _, _, Text),
    sub_string(Text, 0, _, _, "Request "),
    sub_string(Text, _, _, _, " dispatched").

% activity_parts(Set, Parts): Parts divides the
% message set Set at its boundary messages, each
% part beginning with one except possibly the
% first.
activity_parts([], []).
activity_parts([N | Ns], [[N | Part] | Parts]) :-
    take_part(Ns, Part, Rest),
    activity_parts(Rest, Parts).

take_part(Ns, Part, Rest) :-
    (   Ns = [N | Ns1],
        \+ boundary(N)
    ->  Part = [N | Part1],
        take_part(Ns1, Part1, Rest)
    ;   Part = [],
        Rest = Ns
    ).

% glued_activity(TID, Parts): the activity of
% thread TID consists of at least two parts.
glued_activity(TID, Parts) :-
    thread_of_activity(TID, Set),
    activity_parts(Set, Parts),
    Parts = [_, _ | _].

% print_parts(Parts): one line per part with its
% message range and size.
print_parts(Parts) :-
    forall(member(Part, Parts),
           ( Part = [First | _],
             last(Part, Last),
             length(Part, Count),
             format("~t~d~3|-~d~t~7| ~t~d~10|~n",
                    [First, Last, Count]) )).
```

```{.prolog .query}
?- glued_activity(101, _P), print_parts(_P).
  7-7    1
 12-17   6
 53-58   6
 59-60   2
 61-62   2
 63-64   2
 65-66   2
true.

?- glued_activity(T, _P), length(_P, L).
T = 101,
L = 7 ;
T = 102,
L = 2 ;
T = 103,
L = 2 ;
T = 104,
L = 2 ;
false.
```

## 26.11 Resume Activity

```{.prolog .program}
% resume_activity(TID, N, Gap): message N of
% thread TID follows the thread's previous message
% after a gap of Gap ms above the threshold.
resume_activity(TID, N, Gap) :-
    thread_of_activity(TID, Set),
    nextto(Previous, N, Set),
    time_ms(Previous, T1),
    time_ms(N, T2),
    Gap is T2 - T1,
    threshold(resume, Min),
    Gap > Min.
```

```{.prolog .query}
?- resume_activity(101, N, Gap),
   print_messages([N]).
53  9.006 101 appserver    Request 5 dispatched to
N = 53,
Gap = 7695 ;
false.

?- forall(resume_activity(_, N, _),
          print_row(N)).
37  5.001 100 appserver    Request 5 received: GET
71 14.010 100 appserver    Service stopping
53  9.006 101 appserver    Request 5 dispatched to
19  1.501 102 appserver    Request 2 dispatched to
24  2.001 103 appserver    Request 3 dispatched to
28  2.101 104 appserver    Request 4 dispatched to
true.
```

## 26.12 Background and Foreground Components

```{.prolog .program}
% window(From): From is the start of a one-second
% window of the trace.
window(From) :-
    aggregate_all(max(T), msg(_, T, _, _, _, _),
                  End),
    Last is floor(End),
    between(0, Last, From).

% active_window(From): the window has a message.
active_window(From) :-
    window(From),
    To is From + 1,
    msg(_, T, _, _, _, _),
    T >= From, T < To.

% in_window(C, From): the window has a message of
% component C.
in_window(C, From) :-
    window(From),
    To is From + 1,
    msg(_, T, _, _, C, _),
    T >= From, T < To.

% presence(C, Share): C has messages in the share
% Share of the active windows.
presence(C, Share) :-
    aggregate_all(set(C0), msg(_, _, _, _, C0, _),
                  Cs),
    member(C, Cs),
    aggregate_all(count,
                  distinct(F, in_window(C, F)),
                  Own),
    aggregate_all(count,
                  distinct(F, active_window(F)),
                  All),
    Share is Own / All.

print_presence :-
    forall(presence(C, Share),
           format("~a~t~14|~2f~n", [C, Share])).

% background_components(Cs): the components whose
% presence reaches the background threshold.
background_components(Cs) :-
    threshold(background, Min),
    findall(C,
            ( presence(C, Share), Share >= Min ),
            Cs).
```

```{.prolog .query}
?- print_presence.
appserver     0.82
cachelib      0.09
dbclient      0.45
reportengine  0.55
true.

?- background_components(Cs).
Cs = [appserver].
```

```{.prolog .program}
% foreground_components(From, To, Cs): the
% components with messages in From..To that are
% not background components.
foreground_components(From, To, Cs) :-
    window_messages(From, To, Set),
    aggregate_all(set(C),
                  ( member(N, Set),
                    msg(N, _, _, _, C, _) ),
                  Present),
    background_components(Background),
    ord_subtract(Present, Background, Cs).
```

```{.prolog .query}
?- foreground_components(1, 2, Cs).
Cs = [dbclient, reportengine].

?- foreground_components(3, 5, Cs).
Cs = [reportengine].

?- foreground_components(6, 9, Cs).
Cs = [].

?- foreground_components(14, 15, Cs).
Cs = [dbclient].
```

## 26.13 Guest Component

```{.prolog .program}
% guest_component(Set, C): component C has exactly
% one message in Set, which has at least host_size
% messages.
guest_component(Set, C) :-
    length(Set, Size),
    threshold(host_size, Min),
    Size >= Min,
    aggregate_all(set(C0),
                  ( member(N, Set),
                    msg(N, _, _, _, C0, _) ),
                  Cs),
    member(C, Cs),
    aggregate_all(count,
                  ( member(N, Set),
                    msg(N, _, _, _, C, _) ),
                  1).
```

```{.prolog .query}
?- thread_of_activity(T, _S),
   guest_component(_S, C).
T = 100,
C = cachelib ;
T = 103,
C = dbclient ;
T = 104,
C = dbclient ;
false.

?- fiber_of_activity(100, component(cachelib), F),
   print_messages(F).
 3  0.011 100 cachelib     Cache initialized, capa
F = [3].
```

## 26.14 Watch Thread

```{.prolog .program}
% thread_mentions(N, TIDs): the identifiers named
% as worker or thread in the text of message N.
thread_mentions(N, TIDs) :-
    msg(N, _, _, _, _, Text),
    string_lower(Text, Lower),
    string_codes(Lower, Codes),
    phrase(mentions(TIDs), Codes).

mentions(TIDs) -->
    (   ( "worker " ; "thread " ),
        integer(TID)
    ->  { TIDs = [TID | TIDs1] },
        mentions(TIDs1)
    ;   [_]
    ->  mentions(TIDs)
    ;   { TIDs = [] }
    ).

% thread_id(TID): TID is a thread of the trace.
thread_id(TID) :-
    aggregate_all(set(T), msg(_, _, _, T, _, _),
                  TIDs),
    memberchk(TID, TIDs).

% mentioned_thread(N, TID): message N names TID, a
% thread of the trace other than its own.
mentioned_thread(N, TID) :-
    thread_mentions(N, TIDs),
    msg(N, _, _, Own, _, _),
    member(TID, TIDs),
    TID \== Own,
    thread_id(TID).

% watch_thread(TID, Watched): thread TID names at
% least two other threads in its messages.
watch_thread(TID, Watched) :-
    thread_of_activity(TID, Set),
    aggregate_all(set(T),
                  ( member(N, Set),
                    mentioned_thread(N, T) ),
                  Watched),
    Watched = [_, _ | _].
```

```{.prolog .query}
?- thread_mentions(49, Ts).
Ts = [103].

?- thread_mentions(6, Ts).
Ts = [].

?- mentioned_thread(N, T).
N = 49,
T = 103 ;
N = 50,
T = 104 ;
N = 51,
T = 102 ;
N = 52,
T = 101 ;
false.

?- watch_thread(T, W).
T = 108,
W = [101, 102, 103, 104] ;
false.
```

## 26.15 Error Thread

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

% error_thread(TID, Errors): Errors is the
% non-empty set of error messages of thread TID.
error_thread(TID, Errors) :-
    thread_of_activity(TID, Set),
    include(error_message, Set, Errors),
    Errors \== [].
```

```{.prolog .query}
?- error_thread(T, E).
T = 100,
E = [43, 45, 47] ;
T = 109,
E = [69, 70].

?- error_thread(109, _E),
   thread_of_activity(109, _S),
   print_messages(_S).
67 14.000 109 appserver    Request 10 received: GE
68 14.001 109 dbclient     Receive start: session=
69 14.002 109 dbclient     Error: buffer copy fail
70 14.003 109 appserver    Unhandled exception 0xc
true.
```

## 26.16 Error Distribution

```{.prolog .program}
% error_dimension(Dim, N, Value): the value of
% message N along Dim, with second as the integer
% part of its time.
error_dimension(thread, N, TID) :-
    msg(N, _, _, TID, _, _).
error_dimension(component, N, C) :-
    msg(N, _, _, _, C, _).
error_dimension(second, N, S) :-
    msg(N, T, _, _, _, _),
    S is floor(T).

% error_distribution(Dim, Dist): Dist is the list
% of Value-Count pairs of error messages along
% Dim.
error_distribution(Dim, Dist) :-
    findall(V-N,
            ( error_message(N),
              error_dimension(Dim, N, V) ),
            Pairs),
    keysort(Pairs, Sorted),
    group_pairs_by_key(Sorted, Groups),
    maplist(count_group, Groups, Dist).
```

```{.prolog .query}
?- error_distribution(thread, D).
D = [100-3, 109-2].

?- error_distribution(component, D).
D = [appserver-4, dbclient-1].

?- error_distribution(second, D).
D = [7-1, 8-1, 9-1, 14-2].
```

## 26.17 Message Interleave

```{.prolog .program}
% message_interleave(From, To, Count, Switches):
% of the Count messages in From..To, Switches
% consecutive pairs are from different threads.
message_interleave(From, To, Count, Switches) :-
    window_messages(From, To, Set),
    length(Set, Count),
    aggregate_all(count,
                  ( nextto(N1, N2, Set),
                    msg(N1, _, _, T1, _, _),
                    msg(N2, _, _, T2, _, _),
                    T1 \== T2 ),
                  Switches).
```

```{.prolog .query}
?- message_interleave(1.5, 2.2, C, S).
C = 13,
S = 5.

?- message_interleave(9.0, 9.4, C, S).
C = 21,
S = 2.

?- message_interleave(0, 15, C, S).
C = 71,
S = 18.
```

## 26.18 Dominant Event Sequence

```{.prolog .program}
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

% event_sequence(TID, Part, Kinds): Part is a part
% of thread TID's activity that begins at a
% boundary, and Kinds the sequence of its kinds.
event_sequence(TID, Part, Kinds) :-
    thread_of_activity(TID, Set),
    activity_parts(Set, Parts),
    member(Part, Parts),
    Part = [First | _],
    boundary(First),
    maplist(message_kind, Part, Kinds).

% sequence_count(Kinds, Count): the event sequence
% Kinds occurs Count times.
sequence_count(Kinds, Count) :-
    distinct(Kinds, event_sequence(_, _, Kinds)),
    aggregate_all(count,
                  event_sequence(_, _, Kinds),
                  Count).

% dominant_event_sequence(Kinds, Count): the most
% frequent event sequence and its count.
dominant_event_sequence(Kinds, Count) :-
    aggregate_all(max(C, Ks),
                  sequence_count(Ks, C),
                  max(Count, Kinds)).

% print_kinds(Kinds): one kind per line.
print_kinds(Kinds) :-
    forall(member(Kind, Kinds),
           ( truncated(Kind, 46, Short),
             format("  ~s~n", [Short]) )).

% print_sequences(Max): the Max most frequent
% event sequences with their counts.
print_sequences(Max) :-
    forall(limit(Max,
                 order_by([desc(Count)],
                          sequence_count(Kinds,
                                         Count))),
           ( format("count ~d~n", [Count]),
             print_kinds(Kinds) )).
```

```{.prolog .query}
?- dominant_event_sequence(_K, Count),
   print_kinds(_K).
  Request # dispatched to worker #
  Request # completed: #, # ms
Count = 4.

?- print_sequences(2).
count 4
  Request # dispatched to worker #
  Request # completed: #, # ms
count 2
  Request # dispatched to worker #
  Query start: SELECT report #
  Query end: # row, # ms
  Build start: report #
  Build end: report #, # nodes, # ms
  Request # completed: #, # ms
true.

?- aggregate_all(count, sequence_count(_, 1), N).
N = 3.
```

## 26.19 Data Flow

```{.prolog .program}
% key_value(N, Key, Value): the text of message N
% contains the field Key=Value.
key_value(N, Key, Value) :-
    msg(N, _, _, _, _, Text),
    split_string(Text, " ,", "", Parts),
    member(Part, Parts),
    split_string(Part, "=", "", [Key, Value]).

% data_flow(Key, Value, Trail): Trail is the set
% of messages carrying the field Key=Value.
data_flow(Key, Value, Trail) :-
    distinct(Key-Value, key_value(_, Key, Value)),
    aggregate_all(set(N),
                  key_value(N, Key, Value),
                  Trail).
```

```{.prolog .query}
?- data_flow(K, V, T), T = [_, _ | _].
K = "session",
V = "71",
T = [5, 26, 29, 68] ;
false.

?- data_flow("session", "71", _T),
   print_messages(_T).
 5  0.212 100 dbclient     Connected to db01:5432,
26  2.003 103 dbclient     Send start: session=71,
29  2.102 104 dbclient     Reply received: session
68 14.001 109 dbclient     Receive start: session=
true ;
false.

?- data_flow("bytes", V, T).
V = "1024",
T = [26] ;
V = "512",
T = [29] ;
false.
```

## 26.20 Use Case Trail

```{.prolog .program}
% received(R, N), dispatched(R, N, Worker),
% completed(R, N): the lifecycle messages of R.
received(Request, N) :-
    request_id(N, Request),
    msg(N, _, _, _, _, Text),
    sub_string(Text, _, _, _, " received").

dispatched(Request, N, Worker) :-
    request_id(N, Request),
    msg(N, _, _, Worker, _, Text),
    sub_string(Text, _, _, _, " dispatched").

completed(Request, N) :-
    request_id(N, Request),
    msg(N, _, _, _, _, Text),
    sub_string(Text, _, _, _, " completed").

% use_case_trail(Request, Trail): Trail is the set
% of messages serving Request across threads.
use_case_trail(Request, Trail) :-
    received(Request, N0),
    (   dispatched(Request, Start, Worker)
    ->  true
    ;   Start = N0,
        msg(N0, _, _, Worker, _, _)
    ),
    thread_of_activity(Worker, Set),
    append(_, [Start | After], Set),
    take_part(After, Part, _),
    (   completed(Request, End)
    ->  append(Before, [End | _], [Start | Part]),
        append(Before, [End], Segment)
    ;   Segment = [Start | Part]
    ),
    adjoint_thread_of_activity(request(Request),
                               Adjoint),
    ord_union(Adjoint, Segment, Trail).
```

```{.prolog .query}
?- use_case_trail(5, _T), print_messages(_T).
37  5.001 100 appserver    Request 5 received: GET
38  5.002 100 appserver    No idle worker, request
53  9.006 101 appserver    Request 5 dispatched to
54  9.007 101 dbclient     Query start: SELECT rep
55  9.060 101 dbclient     Query end: 1 row, 53 ms
56  9.061 101 reportengine Build start: report 19
57  9.300 101 reportengine Build end: report 19, 2
58  9.301 101 appserver    Request 5 completed: 20
true ;
false.

?- use_case_trail(2, _T), print_messages(_T).
18  1.500 100 appserver    Request 2 received: GET
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
true ;
false.

?- use_case_trail(10, T).
T = [67, 68, 69, 70] ;
false.

?- forall(use_case_trail(R, _T),
          ( length(_T, L),
            format("request ~d: ~d messages~n",
                   [R, L]) )).
request 1: 7 messages
request 2: 11 messages
request 3: 4 messages
request 4: 4 messages
request 5: 8 messages
request 6: 4 messages
request 7: 4 messages
request 8: 3 messages
request 9: 3 messages
request 10: 4 messages
true.
```

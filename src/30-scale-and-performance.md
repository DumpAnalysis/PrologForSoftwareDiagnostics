# Chapter 30. Scale and Performance

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/30-scale-and-performance.md`.

## 30.1 Measuring

```{.prolog .program}
:- [trace1].

% threshold(Pattern, Value)
threshold(discontinuity, 1.0).

% slow_discontinuity(?N, -Gap): pairs of messages,
% then a test. Quadratic in the trace length.
slow_discontinuity(N1, Gap) :-
    msg(N1, T1, _, _, _, _),
    msg(N2, T2, _, _, _, _),
    N2 =:= N1 + 1,
    Gap is T2 - T1,
    threshold(discontinuity, Min),
    Gap > Min.

% discontinuity(?N, -Gap): the next message is
% looked up by number. Linear in the trace length.
discontinuity(N1, Gap) :-
    msg(N1, T1, _, _, _, _),
    N2 is N1 + 1,
    msg(N2, T2, _, _, _, _),
    Gap is T2 - T1,
    threshold(discontinuity, Min),
    Gap > Min.
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.

?- time(aggregate_all(count,
                      slow_discontinuity(_, _),
                      C)).
% <...> inferences, <...> CPU in <...>
C = 1.

?- time(aggregate_all(count, discontinuity(_, _),
                      C)).
% <...> inferences, <...> CPU in <...>
C = 1.

?- discontinuity(N, Gap).
N = 66,
Gap = 4.691000000000001 ;
false.
```

```{.prolog .query}
?- aggregate_all(count, slow_discontinuity(_, _),
                 _),
   statistics(inferences, I0),
   aggregate_all(count, slow_discontinuity(_, _),
                 _),
   statistics(inferences, I1),
   Slow is I1 - I0.
I0 = <...>,
I1 = <...>,
Slow = 5331.

?- aggregate_all(count, discontinuity(_, _), _),
   statistics(inferences, I0),
   aggregate_all(count, discontinuity(_, _), _),
   statistics(inferences, I1),
   Fast is I1 - I0.
I0 = <...>,
I1 = <...>,
Fast = 290.
```

```{.prolog .query}
?- statistics(cputime, T), T > 0.
T = <...>.

?- statistics(runtime, [Total|_]).
Total = <...>.
```

## 30.2 Indexing

```{.prolog .program}
:- [dump1].
```

```{.prolog .query}
?- jiti_list(frame/5).
...
true.

?- frame(107, 3, M, F, O).
M = reportengine,
F = 'Node::Visit',
O = 107.

?- jiti_list(frame/5).
...
user:frame/5<...>1+2<...>
true.

?- aggregate_all(count,
                 frame(_, _, reportengine, _, _),
                 C).
C = 13.

?- jiti_list(frame/5).
...
user:frame/5<...>1+2<...>
<...>3<...>
true.
```

## 30.3 A Synthetic Trace

```{.prolog .program}
:- dynamic smsg/6.

% gen_trace(+N): assert N synthetic messages.
gen_trace(N) :-
    retractall(smsg(_, _, _, _, _, _)),
    forall(between(1, N, I),
           ( Ms is I + 2000 * (I // 1000),
             T is Ms / 1000.0,
             TID is 100 + I mod 5,
             component(I, C),
             assertz(smsg(I, T, 4120, TID, C,
                          "Request")) )).

component(I, C) :-
    K is I mod 3,
    nth0(K, [appserver, dbclient, reportengine],
         C).
```

```{.prolog .query}
?- time(gen_trace(100000)).
% <...> inferences, <...> CPU in <...>
true.

?- aggregate_all(count, smsg(_, _, _, _, _, _),
                 C).
C = 100000.

?- smsg(999, T1, _, _, _, _),
   smsg(1000, T2, _, _, _, _).
T1 = 0.999,
T2 = 3.0.

?- jiti_list(smsg/6).
...
user:smsg/6<...>1<...>
true.
```

```{.prolog .query}
?- time(aggregate_all(count,
                      smsg(_, _, _, 104, _, _),
                      C)).
% <...> inferences, <...> CPU in <...>
C = 20000.

?- time(aggregate_all(count,
                      smsg(_, _, _, 104, _, _),
                      C)).
% <...> inferences, <...> CPU in <...>
C = 20000.

?- jiti_list(smsg/6).
...
user:smsg/6<...>1<...>
<...>4<...>
true.
```

## 30.4 Discontinuity at Scale

```{.prolog .program}
% big_discontinuity(?N, -Gap): Discontinuity over
% the synthetic trace.
big_discontinuity(N1, Gap) :-
    smsg(N1, T1, _, _, _, _),
    N2 is N1 + 1,
    smsg(N2, T2, _, _, _, _),
    Gap is T2 - T1,
    threshold(discontinuity, Min),
    Gap > Min.
```

```{.prolog .query}
?- time(aggregate_all(count,
                      big_discontinuity(_, _),
                      C)).
% <...> inferences, <...> CPU in <...>
C = 100.

?- big_discontinuity(N, Gap), N > 50000,
   format("~d ~3f~n", [N, Gap]).
50999 2.001
N = 50999,
Gap = 2.0010000000000048 ;
51999 2.001
N = 51999,
Gap = 2.0010000000000048 ;
...

?- aggregate_all(count, big_discontinuity(_, _),
                 _),
   statistics(inferences, I0),
   aggregate_all(count, big_discontinuity(_, _),
                 _),
   statistics(inferences, I1),
   Cost is I1 - I0.
I0 = <...>,
I1 = <...>,
Cost = 400204.
```

## 30.5 Facts, Association Lists, and Dicts

```{.prolog .program}
% lookup_facts(+N): N lookups by message number.
lookup_facts(N) :-
    forall(between(1, N, I),
           smsg(I, _, _, _, _, _)).

% lookup_assoc(+N): build an assoc of N pairs and
% look each up.
lookup_assoc(N) :-
    findall(I-I, between(1, N, I), Pairs),
    list_to_assoc(Pairs, Assoc),
    forall(between(1, N, I),
           get_assoc(I, Assoc, _)).

% lookup_dict(+N): the same with a dict built in
% one step.
lookup_dict(N) :-
    findall(I-I, between(1, N, I), Pairs),
    dict_pairs(Dict, t, Pairs),
    forall(between(1, N, I),
           get_dict(I, Dict, _)).

% grow_assoc(+N), grow_dict(+N): build one element
% at a time.
grow_assoc(N) :-
    numlist(1, N, Keys),
    empty_assoc(A0),
    foldl([K, A1, A2]>>put_assoc(K, A1, K, A2),
          Keys, A0, _).

grow_dict(N) :-
    numlist(1, N, Keys),
    foldl([K, D1, D2]>>put_dict(K, D1, K, D2),
          Keys, _{}, _).
```

```{.prolog .query}
?- time(lookup_facts(100000)).
% <...> inferences, <...> CPU in <...>
true.

?- time(lookup_assoc(100000)).
% <...> inferences, <...> CPU in <...>
true.

?- time(lookup_dict(100000)).
% <...> inferences, <...> CPU in <...>
true.

?- time(grow_assoc(10000)).
% <...> inferences, <...> CPU in <...>
true.

?- time(grow_dict(10000)).
% <...> inferences, <...> CPU in <...>
true.

?- time(grow_dict(20000)).
% <...> inferences, <...> CPU in <...>
true.
```

## 30.6 Distinct Values and library(nb_set)

```{.prolog .program}
:- use_module(library(nb_set)).

% threads_nb(-TIDs): distinct threads via nb_set.
threads_nb(TIDs) :-
    empty_nb_set(Set),
    forall(smsg(_, _, _, TID, _, _),
           add_nb_set(TID, Set)),
    nb_set_to_list(Set, TIDs).

% threads_setof(-TIDs): the same via setof/3.
threads_setof(TIDs) :-
    setof(TID, N^T^P^C^X^smsg(N, T, P, TID, C, X),
          TIDs).

% first_message_of_each(-Ns): the number of the
% first message of every thread, in one pass.
first_message_of_each(Ns) :-
    empty_nb_set(Seen),
    findall(N, ( smsg(N, _, _, TID, _, _),
                 add_nb_set(TID, Seen, true) ),
            Ns).
```

```{.prolog .query}
?- time(threads_nb(Ts)).
% <...> inferences, <...> CPU in <...>
Ts = [100, 101, 102, 103, 104].

?- time(threads_setof(Ts)).
% <...> inferences, <...> CPU in <...>
Ts = [100, 101, 102, 103, 104].

?- first_message_of_each(Ns).
Ns = [1, 2, 3, 4, 5].
```

## 30.7 Tabling as Memoization

```{.prolog .program}
:- table thread_messages/2.

% thread_messages(+TID, -Count): messages of TID.
thread_messages(TID, Count) :-
    aggregate_all(count, smsg(_, _, _, TID, _, _),
                  Count).
```

```{.prolog .query}
?- time(thread_messages(102, C)).
% <...> inferences, <...> CPU in <...>
C = 20000.

?- time(thread_messages(102, C)).
% <...> inferences, <...> CPU in <...>
C = 20000.

?- abolish_all_tables.
true.
```

## 30.8 Collecting Less

```{.prolog .query}
?- time(( findall(T, smsg(_, T, _, _, _, _), _Ts),
          length(_Ts, N) )).
% <...> inferences, <...> CPU in <...>
N = 100000.

?- time(aggregate_all(count,
                      smsg(_, _, _, _, _, _), N)).
% <...> inferences, <...> CPU in <...>
N = 100000.

?- time(aggregate_all(max(T),
                      smsg(_, T, _, _, _, _),
                      Last)).
% <...> inferences, <...> CPU in <...>
Last = 300.0.

?- limit(3, smsg(N, _, _, 103, _, _)).
N = 3 ;
N = 8 ;
N = 13.
```

## 30.9 Streaming from Files

```{.prolog .program}
:- use_module(library(dcg/basics)).
:- use_module(library(pure_input)).

% write_log(+File): the synthetic trace as text.
write_log(File) :-
    setup_call_cleanup(
        open(File, write, S),
        forall(smsg(N, T, P, TID, C, Text),
               format(S,
                      "~d ~3f [~d:~d] ~a: ~s~n",
                      [N, T, P, TID, C, Text])),
        close(S)).

% log_line(-N, -Time)//: one line; the rest of the
% line is skipped.
log_line(N, Time) -->
    integer(N), " ", number(Time), " ",
    string_without("\n", _), "\n".

% gaps(+Prev, +C0, -C)//: count the gaps of more
% than a second between consecutive lines.
gaps(Prev, C0, C) -->
    log_line(_, T),
    { (   Prev = time(T0), T - T0 > 1.0
      ->  C1 is C0 + 1
      ;   C1 = C0
      ) },
    gaps(time(T), C1, C).
gaps(_, C, C) -->
    eos.

count_gaps(File, Count) :-
    once(phrase_from_file(gaps(none, 0, Count),
                          File)).
```

```{.prolog .query}
?- time(write_log('big.log')).
% <...> inferences, <...> CPU in <...>
true.

?- time(count_gaps('big.log', Count)).
% <...> inferences, <...> CPU in <...>
Count = 100.
```

```{.prolog .program}
% count_lines(+File, -N): lines of File.
count_lines(File, N) :-
    setup_call_cleanup(
        open(File, read, S),
        count_lines(S, 0, N),
        close(S)).

count_lines(S, N0, N) :-
    read_line_to_string(S, Line),
    (   Line == end_of_file
    ->  N = N0
    ;   N1 is N0 + 1,
        count_lines(S, N1, N)
    ).
```

```{.prolog .query}
?- time(count_lines('big.log', N)).
% <...> inferences, <...> CPU in <...>
N = 100000.
```

```{.prolog .query}
?- open('t.fast', write, _S, [type(binary)]),
   fast_write(_S, smsg(1, 0.001, 4120, 101, a,
                       "x")),
   close(_S).
true.

?- open('t.fast', read, _S, [type(binary)]),
   fast_read(_S, Term),
   close(_S).
Term = smsg(1, 0.001, 4120, 101, a, "x").
```

## 30.10 Stacks and Garbage Collection

```{.prolog .query}
?- current_prolog_flag(stack_limit, Limit).
Limit = 1073741824.

?- set_prolog_flag(stack_limit, 1 000 000),
   catch(length(_L, 100 000 000),
         error(resource_error(R), _), true).
R = stack.

?- set_prolog_flag(stack_limit, 1 073 741 824).
true.
```

```{.prolog .query}
?- garbage_collect, statistics(globalused, G),
   G < 1 000 000.
G = <...>.

?- statistics(garbage_collection, [Count|_]),
   Count > 0.
Count = <...>.
```

## 30.11 Fact Files and Quick-Load Files

```{.prolog .program}
% write_facts(+File): the synthetic trace as facts
% of tmsg/6, so that loading it does not redefine
% the dynamic smsg/6.
write_facts(File) :-
    setup_call_cleanup(
        open(File, write, S),
        forall(smsg(N, T, P, TID, C, Text),
               portray_clause(S,
                   tmsg(N, T, P, TID, C, Text))),
        close(S)).

% count_terms(+File, -N): clauses in a fact file,
% read one at a time.
count_terms(File, N) :-
    setup_call_cleanup(
        open(File, read, S),
        count_terms(S, 0, N),
        close(S)).

count_terms(S, N0, N) :-
    read_term(S, Term, []),
    (   Term == end_of_file
    ->  N = N0
    ;   N1 is N0 + 1,
        count_terms(S, N1, N)
    ).
```

```{.prolog .query}
?- time(write_facts('big.pl')).
% <...> inferences, <...> CPU in <...>
true.

?- time(count_terms('big.pl', N)).
% <...> inferences, <...> CPU in <...>
N = 100000.

?- time(consult(big)).
% <...> inferences, <...> CPU in <...>
true.

?- tmsg(1000, T, _, _, _, _).
T = 3.0.
```

```{.prolog .query}
?- time(qcompile(big)).
% <...> inferences, <...> CPU in <...>
true.

?- exists_file('big.qlf').
true.

?- time(consult('big.qlf')).
% <...> inferences, <...> CPU in <...>
true.

?- time(load_files(big, [qcompile(auto)])).
% <...> inferences, <...> CPU in <...>
true.

?- aggregate_all(count, tmsg(_, _, _, _, _, _),
                 N).
N = 100000.
```

## 30.12 Profiling

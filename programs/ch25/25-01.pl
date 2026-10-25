% 25-01.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 25. Time.
% Program block 1 of the chapter.

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

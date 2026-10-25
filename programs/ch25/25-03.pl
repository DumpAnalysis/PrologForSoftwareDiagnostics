% 25-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 25. Time: 25.1 Time Delta.
% Program block 3 of the chapter.

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

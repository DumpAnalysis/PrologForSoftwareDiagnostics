% 25-16.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 25. Time: 25.13 Punctuated Activity.
% Program block 16 of the chapter.

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

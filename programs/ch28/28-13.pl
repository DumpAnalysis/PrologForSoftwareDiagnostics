% 28-13.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 28. Sequences, Motifs, and Correlation: 28.12 Minimal Trace.
% Program block 13 of the chapter.

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

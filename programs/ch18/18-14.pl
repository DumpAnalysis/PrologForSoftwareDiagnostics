% 18-14.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 18. Stack Traces and Threads: 18.14 Frame Regularity.
% Program block 14 of the chapter.

% runs(List, Runs): Runs is the list of X-N pairs,
% one per maximal run of N consecutive elements
% equal to X in List.
runs([], []).
runs([X | Xs], [X-N | Runs]) :-
    run_length(Xs, X, 1, N, Rest),
    runs(Rest, Runs).

run_length(Xs, X, N0, N, Rest) :-
    (   Xs = [Y | Xs1],
        Y == X
    ->  N1 is N0 + 1,
        run_length(Xs1, X, N1, N, Rest)
    ;   N = N0,
        Rest = Xs
    ).

% frame_regularity(TID, Key, Count): the signature
% of TID has a run of Count frames with Key, Count
% at least the threshold.
frame_regularity(TID, Key, Count) :-
    thread(TID, _),
    stack_trace_signature(TID, Signature),
    runs(Signature, Runs),
    member(Key-Count, Runs),
    threshold(frame_run, Min),
    Count >= Min.

% 09-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 9. Collecting Solutions and Aggregation: 9.5 Pairs and Sorting.
% Program block 3 of the chapter.

% run_counts(Sorted, Counts): Counts is a list of
% X-N pairs, one per run of N identical elements X
% in the sorted list Sorted.
run_counts([], []).
run_counts([X | Xs], [X-N | Counts]) :-
    run_length(Xs, X, 1, N, Rest),
    run_counts(Rest, Counts).

% run_length(Xs, X, N0, N, Rest): N is N0 plus the
% leading elements of Xs identical to X; Rest is
% what follows them.
run_length(Xs, X, N0, N, Rest) :-
    (   Xs = [Y | Xs1],
        Y == X
    ->  N1 is N0 + 1,
        run_length(Xs1, X, N1, N, Rest)
    ;   N = N0,
        Rest = Xs
    ).

% histogram(Values, Counts): Counts is the list of
% Value-Count pairs of Values, most frequent
% first.
histogram(Values, Counts) :-
    msort(Values, Sorted),
    run_counts(Sorted, Counts0),
    predsort(by_count_desc, Counts0, Counts).

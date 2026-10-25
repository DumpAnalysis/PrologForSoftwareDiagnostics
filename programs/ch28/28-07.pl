% 28-07.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 28. Sequences, Motifs, and Correlation: 28.6 Inter-Correlation and Intra-Correlation.
% Program block 7 of the chapter.

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

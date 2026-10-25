% 28-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 28. Sequences, Motifs, and Correlation: 28.5 Dominant Event Sequence.
% Program block 6 of the chapter.

% trace_frame(+Size, ?Index, -Ns): the messages of
% the Index-th window of Size messages.
trace_frame(Size, Index, Ns) :-
    aggregate_all(max(N), msg(N, _, _, _, _, _),
                  Max),
    Frames is (Max + Size - 1) // Size,
    between(1, Frames, Index),
    Lo is (Index - 1) * Size + 1,
    Hi is Index * Size,
    findall(N,
            ( between(Lo, Hi, N),
              msg(N, _, _, _, _, _)
            ),
            Ns).

% modal_kind(+Ns, -Kind): the most frequent kind
% among the messages Ns.
modal_kind(Ns, Kind) :-
    findall(K, ( member(N, Ns), kind(N, K) ), Ks),
    msort(Ks, Sorted),
    run_counts(Sorted, Counts),
    sort(2, @>=, Counts, [Kind-_|_]).

% dominant_event_sequence(+Size, -Seq): the modal
% kind of each non-empty frame of Size messages.
dominant_event_sequence(Size, Seq) :-
    findall(K,
            ( trace_frame(Size, _, Ns),
              Ns \== [],
              modal_kind(Ns, K)
            ),
            Seq).

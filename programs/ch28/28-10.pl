% 28-10.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 28. Sequences, Motifs, and Correlation: 28.9 Impossible Trace.
% Program block 10 of the chapter.

% orderable(+Edges, -Order): Order is a total
% order of the events in Edges satisfying every
% edge; fails when the edges are contradictory.
orderable(Edges, Order) :-
    setof(E,
          X^( member(E-X, Edges)
            ; member(X-E, Edges) ),
          Events),
    pairs_keys_values(Pairs, Events, Vars),
    length(Events, L),
    Vars ins 1..L,
    all_distinct(Vars),
    post_order(Edges, Pairs),
    label(Vars),
    pairs_keys_values(KV, Vars, Events),
    keysort(KV, Sorted),
    pairs_values(Sorted, Order).

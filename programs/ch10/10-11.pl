% 10-11.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 10. Higher-Order Predicates and Libraries: 10.9 Diagnostic Use.
% Program block 11 of the chapter.

% reached_from(V, G, Others): Others are the
% vertices reachable from V in G, other than V;
% [] when V is not a vertex of G.
reached_from(V, G, Others) :-
    (   reachable(V, G, Reached)
    ->  subtract(Reached, [V], Others)
    ;   Others = []
    ).

% waits_on(TID, Others): Others are the threads
% TID waits for, directly or through a chain.
waits_on(TID, Others) :-
    wait_for_graph(G),
    reached_from(TID, G, Others).

% holds_up(TID, Others): Others are the threads
% that wait for TID, directly or through a chain.
holds_up(TID, Others) :-
    wait_for_graph(G),
    transpose_ugraph(G, T),
    reached_from(TID, T, Others).

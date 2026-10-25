% 10-10.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 10. Higher-Order Predicates and Libraries: 10.9 Diagnostic Use.
% Program block 10 of the chapter.

% blocked_by(Waiter, Owner): Waiter waits for a
% critical section that Owner owns.
blocked_by(Waiter, Owner) :-
    waits_for(Waiter, critical_section, Addr),
    critical_section(Addr, Owner, _, _),
    Owner \== 0.

% wait_for_graph(Graph): Graph is the ugraph whose
% edges are the blocked_by/2 pairs of the dump.
wait_for_graph(Graph) :-
    findall(W-O, blocked_by(W, O), Edges),
    vertices_edges_to_ugraph([], Edges, Graph).

% 28-02.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 28. Sequences, Motifs, and Correlation: 28.1 Event Sequence Order.
% Program block 2 of the chapter.

:- use_module(library(clpfd)).

% event_before(?Earlier, ?Later): a known ordering
% constraint between two events.
event_before(connect, query).
event_before(query, build).
event_before(connect, send).
event_before(send, reply).

% event_sequence_order(-Events, -Order): Order
% is a total order of Events consistent with
% every event_before/2 constraint.
event_sequence_order(Events, Order) :-
    setof(E,
          X^( event_before(E, X)
            ; event_before(X, E) ),
          Events),
    pairs_keys_values(Pairs, Events, Vars),
    length(Events, L),
    Vars ins 1..L,
    all_distinct(Vars),
    findall(A-B, event_before(A, B), Edges),
    post_order(Edges, Pairs),
    label(Vars),
    pairs_keys_values(KV, Vars, Events),
    keysort(KV, Sorted),
    pairs_values(Sorted, Order).

% post_order(+Edges, +Pairs): post VA #< VB for
% each edge A-B, where Pairs maps events to vars.
post_order([], _).
post_order([A-B|Edges], Pairs) :-
    memberchk(A-VA, Pairs),
    memberchk(B-VB, Pairs),
    VA #< VB,
    post_order(Edges, Pairs).

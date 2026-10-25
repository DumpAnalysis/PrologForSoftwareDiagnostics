% 27-22.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.20 Message Change.
% Program block 22 of the chapter.

:- multifile msg/7.

msg(t2, 1, 0.000, 4120, 100, tracer,
    "Trace session started, buffer 64 MB").
msg(t2, 2, 0.001, 4120, 100, appserver,
    "Service starting, version 3.3.0.0").
msg(t2, 3, 0.005, 4120, 100, appserver,
    "Loading configuration C:\\App\\app.cfg").
msg(t2, 4, 0.006, 4120, 100, appserver,
    "Error: key proxy missing, default used").
msg(t2, 5, 0.012, 4120, 100, cachelib,
    "Cache initialized, capacity=4096").
msg(t2, 6, 0.016, 4120, 100, dbclient,
    "Connecting to db01:5432").
msg(t2, 7, 0.230, 4120, 100, dbclient,
    "Connected to db01:5432, session=72").
msg(t2, 8, 0.231, 4120, 100, appserver,
    "Worker pool started, threads=4").
msg(t2, 9, 0.900, 4120, 100, tester,
    "MARK: step 1 begin").
msg(t2, 10, 1.002, 4120, 100, appserver,
    "Request 1 accepted: GET /report/17").
msg(t2, 11, 1.003, 4120, 101, appserver,
    "Request 1 dispatched to worker 101").
msg(t2, 12, 1.300, 4120, 101, appserver,
    "Request 1 completed: status=200, 297 ms").
msg(t2, 13, 1.400, 4120, 100, tester,
    "MARK: step 1 end").
msg(t2, 14, 1.500, 4120, 100, appserver,
    "Service stoppinged to worker 101").
msg(t2, 15, 1.501, 4120, 100, tracer,
    "Trace session stopped, events lost: 0").

% trace_text(?Trace, ?N, ?TID, ?Component, ?Text):
% a view over trace1 (msg/6) and the in-chapter
% traces (msg/7).
trace_text(trace1, N, TID, C, Text) :-
    msg(N, _, _, TID, C, Text).
trace_text(T, N, TID, C, Text) :-
    msg(T, N, _, _, TID, C, Text).

% trace_invariant(+Trace, ?Inv): Inv is an
% invariant of Trace; each once.
trace_invariant(T, Inv) :-
    distinct(Inv, ( trace_text(T, _, _, _, Text),
                    invariant(Text, Inv) )).

% similarity(+S1, +S2, -Sim): the share of words
% the two strings have in common.
similarity(S1, S2, Sim) :-
    split_string(S1, " ", ",:", W1),
    split_string(S2, " ", ",:", W2),
    intersection(W1, W2, Shared),
    length(Shared, N),
    length(W1, L1),
    length(W2, L2),
    Sim is N / max(L1, L2).

% message_change(+Old, +New, -OldInv, -NewInv):
% NewInv occurs in New only, and OldInv is the
% invariant of Old only that is most similar to
% it, at least half its words.
message_change(Old, New, OldInv, NewInv) :-
    trace_invariant(New, NewInv),
    \+ trace_invariant(Old, NewInv),
    aggregate_all(max(S, I),
                  ( trace_invariant(Old, I),
                    \+ trace_invariant(New, I),
                    similarity(NewInv, I, S)
                  ),
                  max(S, OldInv)),
    S >= 0.5.

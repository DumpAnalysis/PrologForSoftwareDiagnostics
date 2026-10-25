% 27-28.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.26 Recovered Messages.
% Program block 28 of the chapter.

% recovered(?Id, ?Text): a record recovered from
% the tracing buffer in the memory dump.
recovered(1, "ispatched to worker 102").
recovered(2, "Query start: SELECT report 18").
recovered(3,
    "Warning: table resize, 524288 -> 1048576").

% recovered_messages(?Id, -Inv): the recovered
% record Id ends like the trace invariant Inv.
recovered_messages(Id, Inv) :-
    recovered(Id, Text),
    invariant(Text, Fragment),
    distinct(Inv, message_invariant(_, Inv)),
    sub_string(Inv, _, _, 0, Fragment).

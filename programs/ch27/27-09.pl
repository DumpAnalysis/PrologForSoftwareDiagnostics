% 27-09.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.8 Characteristic Message Block.
% Program block 9 of the chapter.

% characteristic_block(?Name, ?Prefixes): the
% block Name is the sequence of message kinds
% Prefixes.
characteristic_block(report_request,
    [ "Request # dispatched", "Query start",
      "Query end", "Build start", "Build end",
      "Request # completed" ]).

% characteristic_message_block(?Name, ?TID, -Ns):
% the consecutive messages Ns of thread TID form
% an instance of the block Name.
characteristic_message_block(Name, TID, Ns) :-
    characteristic_block(Name, Prefixes),
    trace_thread(TID),
    thread_sequence(TID, Seq),
    append(_, Rest, Seq),
    append(Ns, _, Rest),
    maplist(prefix_of, Prefixes, Ns).

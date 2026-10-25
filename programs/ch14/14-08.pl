% 14-08.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 14. Constraints and Coroutining: 14.4 Reconstructing an Event Order.
% Program block 8 of the chapter.

% ms(Seconds, Ms): Ms is Seconds as integer ms.
ms(Seconds, Ms) :-
    Ms is round(Seconds * 1000).

% request_events(R, Events): the lifecycle events
% of request R found in the trace, as Name-Ms.
request_events(R, [received-Tr, dispatched-Td
                   | Rest]) :-
    once(request_msg(R, "received", _, Tr)),
    once(request_msg(R, "dispatched", W, Td)),
    (   once(request_msg(R, "completed", W, Tc))
    ->  true
    ;   Tc = inf
    ),
    findall(Name-T,
            worker_event(W, Td, Tc, Name, T),
            Rest).

request_msg(R, Verb, TID, Ms) :-
    format(string(Prefix), "Request ~w ~s",
           [R, Verb]),
    msg(_, Time, _, TID, appserver, Text),
    string_concat(Prefix, _, Text),
    ms(Time, Ms).

worker_event(W, Td, Tc, Name, Ms) :-
    msg(_, Time, _, W, _, Text),
    ms(Time, Ms),
    Ms > Td,
    Ms =< Tc,
    event_prefix(Prefix, Name),
    string_concat(Prefix, _, Text).

event_prefix("Query start", query_start).
event_prefix("Query end", query_end).
event_prefix("Build start", build_start).
event_prefix("Build end", build_end).
event_prefix("Request", completed).

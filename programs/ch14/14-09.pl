% 14-09.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 14. Constraints and Coroutining: 14.5 Deducing a Counter.
% Program block 9 of the chapter.

:- use_module(library(pcre)).

% queue_event(N, Event): message N of the trace
% is an event of the request queue.
queue_event(N, Event) :-
    msg(N, _, _, _, appserver, Text),
    queue_text(Text, Event).

queue_text(Text, received(R)) :-
    re_matchsub("^Request (?<r_I>\\d+) received",
                Text, Sub, []),
    get_dict(r, Sub, R).
queue_text(Text, queued(R)) :-
    re_matchsub("request (?<r_I>\\d+) queued$",
                Text, Sub, []),
    get_dict(r, Sub, R).
queue_text(Text, dispatched(R)) :-
    re_matchsub("^Request (?<r_I>\\d+) dispatch",
                Text, Sub, []),
    get_dict(r, Sub, R).
queue_text(Text, depth(D)) :-
    re_matchsub("queue depth (?<d_I>\\d+)",
                Text, Sub, []),
    get_dict(d, Sub, D).

% queue_events(From, To, Events): the queue events
% of messages From to To, in order.
queue_events(From, To, Events) :-
    findall(E, ( between(From, To, N),
                 queue_event(N, E) ),
            Events).

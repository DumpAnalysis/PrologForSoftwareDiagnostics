% 24-14.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 24. Trace Structure: 24.12 Trace Extension.
% Program block 14 of the chapter.

% extension_msg(N, Time, PID, TID, Component,
% Text): messages recorded after trace1 ends.
extension_msg(72, 14.011, 4120, 100, appserver,
    "Worker pool stopping").
extension_msg(73, 14.512, 4120, 100, dbclient,
    "Disconnected from db01:5432, session=71").
extension_msg(74, 14.513, 4120, 100, appserver,
    "Service stopped").

% trace_extension(Added): Added is the set of
% extension messages numbered after the trace.
trace_extension(Added) :-
    message_space(Space),
    tail_message(Space, Last),
    findall(N,
            ( extension_msg(N, _, _, _, _, _),
              N > Last ),
            Ns),
    sort(Ns, Added).

% extended_span(First, Last): the time span of the
% trace together with its extension.
extended_span(First, Last) :-
    aggregate_all(min(T), msg(_, T, _, _, _, _),
                  First),
    aggregate_all(max(T), any_msg(T), Last).

any_msg(T) :- msg(_, T, _, _, _, _).
any_msg(T) :- extension_msg(_, T, _, _, _, _).

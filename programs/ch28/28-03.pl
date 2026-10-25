% 28-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 28. Sequences, Motifs, and Correlation: 28.2 Event Sequence Phase.
% Program block 3 of the chapter.

% phase_boundaries(-Bs): the first message
% number of each phase after startup, in order.
phase_boundaries([B1, B2, B3, B4, B5]) :-
    aggregate_all(min(N), kind(N, received), B1),
    aggregate_all(min(N), kind(N, queued), B2),
    aggregate_all(min(N),
        ( text_of(N, T),
          sub_string(T, 0, _, _, "Housekeeping")
        ), B3),
    aggregate_all(min(N), msg(N, _, _, 109, _, _),
                  B4),
    aggregate_all(min(N),
        ( text_of(N, T),
          sub_string(T, 0, _, _,
                    "Service stopping")
        ), B5).

% message_phase(?N, -Phase): N's phase.
message_phase(N, Phase) :-
    phase_boundaries([B1, B2, B3, B4, B5]),
    msg(N, _, _, _, _, _),
    (   N >= B5 ->  Phase = shutdown
    ;   N >= B4 ->  Phase = failure
    ;   N >= B3 ->  Phase = drain
    ;   N >= B2 ->  Phase = saturation
    ;   N >= B1 ->  Phase = serving
    ;   Phase = startup
    ).

% phase_extent(?Phase, -Lo-Hi, -Count): the first
% and last message of Phase and how many it holds.
phase_extent(Phase, Lo-Hi, Count) :-
    distinct(Phase, message_phase(_, Phase)),
    findall(N, message_phase(N, Phase), Ns),
    min_list(Ns, Lo),
    max_list(Ns, Hi),
    length(Ns, Count).

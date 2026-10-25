% 26-20.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 26. Activities and Threads of Activity: 26.18 Dominant Event Sequence.
% Program block 20 of the chapter.

:- table message_kind/2.

% message_kind(N, Kind): the text of message N
% with every number replaced by # (Chapter 24).
message_kind(N, Kind) :-
    msg(N, _, _, _, _, Text),
    string_codes(Text, Codes),
    phrase(kind(KindCodes), Codes),
    string_codes(Kind, KindCodes).

kind(Ks) -->
    (   number_token
    ->  { Ks = [0'# | Ks1] },
        kind(Ks1)
    ;   [C]
    ->  { Ks = [C | Ks1] },
        kind(Ks1)
    ;   { Ks = [] }
    ).

number_token -->
    (   "0x"
    ->  xinteger(_)
    ;   integer(_)
    ).

% event_sequence(TID, Part, Kinds): Part is a part
% of thread TID's activity that begins at a
% boundary, and Kinds the sequence of its kinds.
event_sequence(TID, Part, Kinds) :-
    thread_of_activity(TID, Set),
    activity_parts(Set, Parts),
    member(Part, Parts),
    Part = [First | _],
    boundary(First),
    maplist(message_kind, Part, Kinds).

% sequence_count(Kinds, Count): the event sequence
% Kinds occurs Count times.
sequence_count(Kinds, Count) :-
    distinct(Kinds, event_sequence(_, _, Kinds)),
    aggregate_all(count,
                  event_sequence(_, _, Kinds),
                  Count).

% dominant_event_sequence(Kinds, Count): the most
% frequent event sequence and its count.
dominant_event_sequence(Kinds, Count) :-
    aggregate_all(max(C, Ks),
                  sequence_count(Ks, C),
                  max(Count, Kinds)).

% print_kinds(Kinds): one kind per line.
print_kinds(Kinds) :-
    forall(member(Kind, Kinds),
           ( truncated(Kind, 46, Short),
             format("  ~s~n", [Short]) )).

% print_sequences(Max): the Max most frequent
% event sequences with their counts.
print_sequences(Max) :-
    forall(limit(Max,
                 order_by([desc(Count)],
                          sequence_count(Kinds,
                                         Count))),
           ( format("count ~d~n", [Count]),
             print_kinds(Kinds) )).

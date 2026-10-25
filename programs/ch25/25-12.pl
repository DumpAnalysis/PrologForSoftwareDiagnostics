% 25-12.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 25. Time: 25.9 Periodic Error.
% Program block 12 of the chapter.

% error_word(Word): a word marking an error.
error_word("Error").
error_word("exception").
error_word("failed").

% error_message(N): message N contains an error
% word.
error_message(N) :-
    msg(N, _, _, _, _, Text),
    once(( error_word(Word),
           sub_string(Text, _, _, _, Word) )).

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

% kind_messages(Kind, Set): the non-empty set of
% messages of kind Kind.
kind_messages(Kind, Set) :-
    aggregate_all(set(N), message_kind(N, Kind),
                  Set),
    Set \== [].

% periodic(Set, Period): the messages of Set, at
% least three, are Period ms apart within the
% tolerance, and Period is at least min_period.
periodic(Set, Period) :-
    Set = [_, _, _ | _],
    maplist(time_ms, Set, Times),
    changes(Times, [Period | Deltas]),
    threshold(min_period, MinPeriod),
    Period >= MinPeriod,
    threshold(period_tolerance, Tolerance),
    forall(member(D, Deltas),
           abs(D - Period) =< Tolerance).

% periodic_error(Kind, Set, Period): the error
% messages of kind Kind recur with Period.
periodic_error(Kind, Set, Period) :-
    distinct(Kind, ( error_message(N),
                     message_kind(N, Kind) )),
    kind_messages(Kind, Set),
    periodic(Set, Period).

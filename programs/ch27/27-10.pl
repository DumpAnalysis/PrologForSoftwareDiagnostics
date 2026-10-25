% 27-10.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.9 Missing Message.
% Program block 10 of the chapter.

% missing_message(?Name, ?TID, -Ns, -Expected):
% the messages Ns of thread TID match a proper
% prefix of the block Name, at least two messages
% long, and the block's next kind, Expected, does
% not follow.
missing_message(Name, TID, Ns, Expected) :-
    characteristic_block(Name, Prefixes),
    trace_thread(TID),
    thread_sequence(TID, Seq),
    append(_, Rest, Seq),
    matched_prefix(Prefixes, Rest, Ns, Missing),
    Ns = [_, _|_],
    Missing = [Expected|_].

% matched_prefix(+Prefixes, +Seq, -Ns, -Missing):
% Ns are the leading messages of Seq that match
% the leading Prefixes in order; Missing are the
% prefixes left unmatched.
matched_prefix([], _, [], []).
matched_prefix([P|Ps], Seq, Ns, Missing) :-
    (   Seq = [N|Seq1],
        prefix_of(P, N)
    ->  Ns = [N|Ns1],
        matched_prefix(Ps, Seq1, Ns1, Missing)
    ;   Ns = [],
        Missing = [P|Ps]
    ).

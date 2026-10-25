% 18-12.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 18. Stack Traces and Threads: 18.12 Least Common Frame.
% Program block 12 of the chapter.

% reversed_signature(TID, Reversed): the signature
% of TID from the bottom frame up.
reversed_signature(TID, Reversed) :-
    stack_trace_signature(TID, Signature),
    reverse(Signature, Reversed).

% common_prefix(Lists, Prefix): Prefix is the
% longest list that every list in Lists begins
% with.
common_prefix(Lists, Prefix) :-
    (   Lists = [[X | _] | _],
        forall(member(L, Lists), L = [X | _])
    ->  maplist(list_tail, Lists, Tails),
        common_prefix(Tails, Prefix0),
        Prefix = [X | Prefix0]
    ;   Prefix = []
    ).

list_tail([_ | Tail], Tail).

% least_common_frame(TIDs, Key): Key is the
% topmost frame key shared, as a common suffix, by
% the stack traces of all threads in TIDs.
least_common_frame(TIDs, Key) :-
    maplist(reversed_signature, TIDs, Reversed),
    common_prefix(Reversed, Common),
    last(Common, Key).

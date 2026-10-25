% 27-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.4 Counter Value.
% Program block 5 of the chapter.

% numbers_in(+Text, -Numbers): the numbers in Text
% that number_string/2 accepts, in order.
numbers_in(Text, Numbers) :-
    split_string(Text, " ,:=%", " ,:=%", Parts),
    convlist([P, V]>>number_string(V, P), Parts,
             Numbers).

% counter_value(?Inv, ?I, -Series): Series is the
% list of N-Value pairs of the I-th number of the
% messages with invariant Inv; it has at least two
% elements and is not constant.
counter_value(Inv, I, Series) :-
    distinct(Inv, message_invariant(_, Inv)),
    findall(N-Vs,
            ( message_invariant(N, Inv),
              text_of(N, Text),
              numbers_in(Text, Vs)
            ),
            Rows),
    Rows = [_-Vs0|_],
    length(Vs0, K),
    between(1, K, I),
    findall(N-V,
            ( member(N-Vs, Rows),
              nth1(I, Vs, V)
            ),
            Series),
    Series = [_, _|_],
    pairs_values(Series, [V0|Values]),
    \+ maplist(==(V0), Values).

% increasing(+Values): each value exceeds the one
% before it.
increasing([_]).
increasing([A, B|Rest]) :-
    A < B,
    increasing([B|Rest]).

% print_series(+Series): one line per pair.
print_series(Series) :-
    forall(member(N-V, Series),
           format("~t~d~3| ~w~n", [N, V])).

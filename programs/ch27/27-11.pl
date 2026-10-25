% 27-11.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.10 Ordinals in Messages.
% Program block 11 of the chapter.

% ordinal_message(+Prefix, -Ordinals): Ordinals
% are the request numbers of the messages of kind
% Prefix, in trace order.
ordinal_message(Prefix, Ordinals) :-
    findall(O,
            ( prefix_of(Prefix, N),
              message_key(N, "request"-S),
              number_string(O, S)
            ),
            Ordinals).

% missing_ordinals(+Ordinals, -Missing): the
% numbers between the least and the greatest of
% Ordinals that do not occur in it.
missing_ordinals(Ordinals, Missing) :-
    min_list(Ordinals, Min),
    max_list(Ordinals, Max),
    numlist(Min, Max, All),
    subtract(All, Ordinals, Missing).

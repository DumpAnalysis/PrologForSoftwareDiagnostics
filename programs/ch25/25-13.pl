% 25-13.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 25. Time: 25.10 Periodic Message Block.
% Program block 13 of the chapter.

% block_kinds(N, Length, Kinds): Kinds are the
% kinds of the Length messages from N on.
block_kinds(N, Length, Kinds) :-
    msg(N, _, _, _, _, _),
    Last is N + Length - 1,
    numlist(N, Last, Ns),
    maplist(message_kind, Ns, Kinds).

% periodic_message_block(Length, Kinds, Starts,
% Period): the block Kinds of Length messages
% starts at each message in Starts, periodically.
periodic_message_block(Length, Kinds, Starts,
                       Period) :-
    distinct(Kinds,
             block_kinds(_, Length, Kinds)),
    aggregate_all(set(N),
                  block_kinds(N, Length, Kinds),
                  Starts),
    periodic(Starts, Period).

% print_kinds(Kinds): one kind per line, indented.
print_kinds(Kinds) :-
    forall(member(Kind, Kinds),
           ( truncated(Kind, 46, Short),
             format("  ~s~n", [Short]) )).

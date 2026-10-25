% 27-30.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.28 Message Cover.
% Program block 30 of the chapter.

% message_set(?Name, ?N): message N belongs to the
% named set.
message_set(lifecycle, N) :-
    prefix_of("Service", N).
message_set(identity, N) :-
    identification_messages(Ns),
    member(N, Ns).
message_set(workers, N) :-
    prefix_of("Worker", N).
message_set(request, N) :-
    message_key(N, "request"-_).
message_set(session, N) :-
    message_key(N, Key),
    key_word(Key, "session").
message_set(query, N) :-
    prefix_of("Query", N).
message_set(build, N) :-
    prefix_of("Build", N).
message_set(resize, N) :-
    prefix_of("Warning: table resize", N).
message_set(housekeeping, N) :-
    prefix_of("Housekeeping", N).
message_set(error, N) :-
    error_message(N).
message_set(error, N) :-
    hidden_error(N).
message_set(frames, N) :-
    frame_message(N, _).

% message_cover(+Names, -Uncovered): Uncovered are
% the messages that belong to none of the named
% sets.
message_cover(Names, Uncovered) :-
    findall(N,
            ( msg(N, _, _, _, _, _),
              \+ ( member(S, Names),
                   message_set(S, N) )
            ),
            Uncovered).

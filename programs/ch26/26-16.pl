% 26-16.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 26. Activities and Threads of Activity: 26.14 Watch Thread.
% Program block 16 of the chapter.

% thread_mentions(N, TIDs): the identifiers named
% as worker or thread in the text of message N.
thread_mentions(N, TIDs) :-
    msg(N, _, _, _, _, Text),
    string_lower(Text, Lower),
    string_codes(Lower, Codes),
    phrase(mentions(TIDs), Codes).

mentions(TIDs) -->
    (   ( "worker " ; "thread " ),
        integer(TID)
    ->  { TIDs = [TID | TIDs1] },
        mentions(TIDs1)
    ;   [_]
    ->  mentions(TIDs)
    ;   { TIDs = [] }
    ).

% thread_id(TID): TID is a thread of the trace.
thread_id(TID) :-
    aggregate_all(set(T), msg(_, _, _, T, _, _),
                  TIDs),
    memberchk(TID, TIDs).

% mentioned_thread(N, TID): message N names TID, a
% thread of the trace other than its own.
mentioned_thread(N, TID) :-
    thread_mentions(N, TIDs),
    msg(N, _, _, Own, _, _),
    member(TID, TIDs),
    TID \== Own,
    thread_id(TID).

% watch_thread(TID, Watched): thread TID names at
% least two other threads in its messages.
watch_thread(TID, Watched) :-
    thread_of_activity(TID, Set),
    aggregate_all(set(T),
                  ( member(N, Set),
                    mentioned_thread(N, T) ),
                  Watched),
    Watched = [_, _ | _].

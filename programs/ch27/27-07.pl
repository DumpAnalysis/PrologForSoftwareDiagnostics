% 27-07.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.6 Shared Point.
% Program block 7 of the chapter.

% shared_point(?Key, -TIDs): Key occurs in
% messages of at least two threads, TIDs.
shared_point(Key, TIDs) :-
    distinct(Key, message_key(_, Key)),
    aggregate_all(set(TID),
                  ( message_key(N, Key),
                    msg(N, _, _, TID, _, _)
                  ),
                  TIDs),
    TIDs = [_, _|_].

% 27-08.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.7 Opposition Messages.
% Program block 8 of the chapter.

% opposition(?Open, ?Close, ?Scope): messages
% beginning with Open and Close bracket an
% activity; Scope is thread or a key word.
opposition("Query start", "Query end", thread).
opposition("Build start", "Build end", thread).
opposition("Service starting", "Service stopping",
           thread).
opposition("Send start", "Reply received",
           "session").
opposition("Request # received",
           "Request # completed", "request").
opposition("Request # dispatched",
           "Request # completed", "request").

% key_word(+Key, -Word): the name part of a key.
key_word(Name-_, Name).
key_word(Key, Name) :-
    string(Key),
    sub_string(Key, B, _, _, "="),
    sub_string(Key, 0, B, _, Name).

% in_scope(+Scope, +N1, +N2): N1 and N2 belong to
% the same activity under Scope.
in_scope(thread, N1, N2) :-
    msg(N1, _, _, TID, _, _),
    msg(N2, _, _, TID, _, _).
in_scope(Word, N1, N2) :-
    string(Word),
    once(( message_key(N1, Key),
           key_word(Key, Word),
           message_key(N2, Key) )).

% opposition_messages(?N1, ?N2): N2 is the closing
% message matching the opening message N1.
opposition_messages(N1, N2) :-
    opposition(Open, Close, Scope),
    prefix_of(Open, N1),
    prefix_of(Close, N2),
    N1 < N2,
    in_scope(Scope, N1, N2),
    \+ ( prefix_of(Open, N3), N1 < N3, N3 < N2,
         in_scope(Scope, N1, N3) ),
    \+ ( prefix_of(Close, N3), N1 < N3, N3 < N2,
         in_scope(Scope, N1, N3) ).

% unmatched_open(?N): N opens an activity that no
% message closes.
unmatched_open(N) :-
    opposition(Open, _, _),
    prefix_of(Open, N),
    \+ opposition_messages(N, _).

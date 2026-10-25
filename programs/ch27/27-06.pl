% 27-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.5 Linked Messages.
% Program block 6 of the chapter.

% id_word(?Word): Word, lowercased, introduces an
% identifier in this application's messages.
id_word("request").
id_word("report").
id_word("worker").
id_word("thread").
id_word("session").

% message_key(?N, ?Key): Key is a name=value token
% of message N, or a Name-Number pair of adjacent
% words where Name is an id_word/1.
message_key(N, Key) :-
    text_of(N, Text),
    split_string(Text, " ,:", " ,:", Words),
    (   member(Key, Words),
        sub_string(Key, _, _, _, "=")
    ;   nextto(Name, Number, Words),
        number_string(_, Number),
        string_lower(Name, Lower),
        id_word(Lower),
        Key = Lower-Number
    ).

% linked_messages(?N1, ?N2, ?Key): messages N1 and
% N2, N1 before N2, share Key.
linked_messages(N1, N2, Key) :-
    message_key(N1, Key),
    message_key(N2, Key),
    N1 < N2.

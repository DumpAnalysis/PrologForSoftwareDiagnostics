% 26-21.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 26. Activities and Threads of Activity: 26.19 Data Flow.
% Program block 21 of the chapter.

% key_value(N, Key, Value): the text of message N
% contains the field Key=Value.
key_value(N, Key, Value) :-
    msg(N, _, _, _, _, Text),
    split_string(Text, " ,", "", Parts),
    member(Part, Parts),
    split_string(Part, "=", "", [Key, Value]).

% data_flow(Key, Value, Trail): Trail is the set
% of messages carrying the field Key=Value.
data_flow(Key, Value, Trail) :-
    distinct(Key-Value, key_value(_, Key, Value)),
    aggregate_all(set(N),
                  key_value(N, Key, Value),
                  Trail).

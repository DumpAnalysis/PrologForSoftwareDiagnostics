% 09-10.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 9. Collecting Solutions and Aggregation: 9.6 Diagnostic Use.
% Program block 10 of the chapter.

% message_word(Word): Word is a lowercased word of
% the text of some message of the trace.
message_word(Word) :-
    msg(_, _, _, _, _, Text),
    split_string(Text, " ,:=", " ,:=", Parts),
    member(Part, Parts),
    string_lower(Part, Word).

% word_count(Word, Count): Word occurs Count times
% in the trace.
word_count(Word, Count) :-
    aggregate_all(count, message_word(Word),
                  Count).

% vocabulary(Index): Index is the list of
% Word-Count pairs of the trace, most frequent
% first.
vocabulary(Index) :-
    findall(Word, message_word(Word), Words),
    histogram(Words, Index).

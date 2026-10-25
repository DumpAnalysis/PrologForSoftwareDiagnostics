% 27-17.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.16 Implementation Discourse.
% Program block 17 of the chapter.

% implementation_word(?Word): Word belongs to the
% implementation level of the messages.
implementation_word("0x").
implementation_word("thread").
implementation_word("table").
implementation_word("buffer").
implementation_word("cpu").
implementation_word("pool").
implementation_word("Cache").

% implementation_discourse(?N): message N uses
% implementation vocabulary.
implementation_discourse(N) :-
    text_of(N, Text),
    once(( implementation_word(W),
           sub_string(Text, _, _, _, W) )).

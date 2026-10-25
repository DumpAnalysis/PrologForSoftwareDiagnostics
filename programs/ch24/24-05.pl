% 24-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 24. Trace Structure: 24.4 Vocabulary Index.
% Program block 5 of the chapter.

% word_separators(Seps): the characters at which
% message text is split into words.
word_separators(" ,:=/\\.()->%").

% word_of(N, Word): Word is a lowercased word of
% the text of message N.
word_of(N, Word) :-
    msg(N, _, _, _, _, Text),
    word_separators(Seps),
    split_string(Text, Seps, Seps, Parts),
    member(Part, Parts),
    Part \== "",
    string_lower(Part, Word).

% lexical(Word): Word begins with a letter.
lexical(Word) :-
    string_code(1, Word, C),
    code_type(C, alpha).

% word_messages(Word, Set): Set is the non-empty
% set of messages containing Word.
word_messages(Word, Set) :-
    aggregate_all(set(N), word_of(N, Word), Set),
    Set \== [].

% vocabulary_index(Index): Index is the list of
% Word-Set pairs, one per distinct word, in the
% standard order of the words.
vocabulary_index(Index) :-
    findall(Word-N, word_of(N, Word), Pairs),
    keysort(Pairs, Sorted),
    group_pairs_by_key(Sorted, Groups),
    maplist(dedupe, Groups, Index).

dedupe(Word-Ns, Word-Set) :-
    sort(Ns, Set).

% print_vocabulary(Max): the Max most frequent
% lexical words with their message counts.
print_vocabulary(Max) :-
    vocabulary_index(Index),
    forall(limit(Max,
                 order_by([desc(Count)],
                          frequent(Index, Word,
                                   Count))),
           format("~t~d~3| ~s~n", [Count, Word])).

frequent(Index, Word, Count) :-
    member(Word-Set, Index),
    lexical(Word),
    length(Set, Count).

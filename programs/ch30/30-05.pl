% 30-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 30. Scale and Performance: 30.5 Facts, Association Lists, and Dicts.
% Program block 5 of the chapter.

% lookup_facts(+N): N lookups by message number.
lookup_facts(N) :-
    forall(between(1, N, I),
           smsg(I, _, _, _, _, _)).

% lookup_assoc(+N): build an assoc of N pairs and
% look each up.
lookup_assoc(N) :-
    findall(I-I, between(1, N, I), Pairs),
    list_to_assoc(Pairs, Assoc),
    forall(between(1, N, I),
           get_assoc(I, Assoc, _)).

% lookup_dict(+N): the same with a dict built in
% one step.
lookup_dict(N) :-
    findall(I-I, between(1, N, I), Pairs),
    dict_pairs(Dict, t, Pairs),
    forall(between(1, N, I),
           get_dict(I, Dict, _)).

% grow_assoc(+N), grow_dict(+N): build one element
% at a time.
grow_assoc(N) :-
    numlist(1, N, Keys),
    empty_assoc(A0),
    foldl([K, A1, A2]>>put_assoc(K, A1, K, A2),
          Keys, A0, _).

grow_dict(N) :-
    numlist(1, N, Keys),
    foldl([K, D1, D2]>>put_dict(K, D1, K, D2),
          Keys, _{}, _).

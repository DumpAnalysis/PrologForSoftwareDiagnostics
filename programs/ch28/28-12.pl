% 28-12.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 28. Sequences, Motifs, and Correlation: 28.11 Dialogue.
% Program block 12 of the chapter.

% keyed_message(?N, -TID, -Key): message N on
% thread TID bears the session Key.
keyed_message(N, TID, Key) :-
    msg(N, _, _, TID, _, Text),
    session_token(Text, Key).

% dialogue(?Key, -Turns): the turns of the
% dialogue on Key, as N-TID pairs in order, when
% at least two threads take part.
dialogue(Key, Turns) :-
    distinct(Key, keyed_message(_, _, Key)),
    aggregate_all(set(TID),
                  keyed_message(_, TID, Key),
                  TIDs),
    TIDs = [_, _|_],
    findall(N-TID, keyed_message(N, TID, Key),
            Turns0),
    sort(Turns0, Turns).

% 09-11.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 9. Collecting Solutions and Aggregation: 9.6 Diagnostic Use.
% Program block 11 of the chapter.

% rare_word(Word): Word occurs once in the trace
% and begins with a lowercase letter.
rare_word(Word) :-
    vocabulary(Index),
    member(Word-1, Index),
    string_code(1, Word, C),
    C >= 0'a,
    C =< 0'z.

% print_columns(Words): print Words three to a
% line in 16-character columns.
print_columns(Words) :-
    forall(nth1(I, Words, W),
           ( Stop is 16 * ((I - 1) mod 3 + 1),
             format("~s~t~*|", [W, Stop]),
             (   I mod 3 =:= 0
             ->  nl
             ;   true
             )
           )),
    nl.

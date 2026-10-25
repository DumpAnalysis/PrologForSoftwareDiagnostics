% 28-17.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 28. Sequences, Motifs, and Correlation: 28.16 State Dump.
% Program block 17 of the chapter.

% numbers_in(+Text, -Numbers): Text's numbers.
numbers_in(Text, Numbers) :-
    split_string(Text, " ,->", " ,->", Parts),
    convlist([P, V]>>number_string(V, P), Parts,
             Numbers).

% state_dump(?N, -Before, -After): message N
% dumps a table resize from Before to After.
state_dump(N, Before, After) :-
    kind(N, resize),
    text_of(N, Text),
    numbers_in(Text, [Before, After]).

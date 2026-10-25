% 27-04.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.3 Message Invariant.
% Program block 4 of the chapter.

% invariant(+Text, -Inv): Inv is Text with every
% number replaced by #.
invariant(Text, Inv) :-
    string_codes(Text, Codes),
    blank_numbers(Codes, Skeleton),
    string_codes(Inv, Skeleton).

blank_numbers([], []).
blank_numbers([C|Cs], Skeleton) :-
    (   code_type(C, digit)
    ->  skip_number(Cs, Rest),
        Skeleton = [0'#|Skeleton1],
        blank_numbers(Rest, Skeleton1)
    ;   Skeleton = [C|Skeleton1],
        blank_numbers(Cs, Skeleton1)
    ).

% skip_number(+Cs, -Rest): Rest is Cs without its
% leading letters, digits, and dots.
skip_number(Cs, Rest) :-
    (   Cs = [C|Cs1],
        (   code_type(C, alnum)
        ;   C == 0'.
        )
    ->  skip_number(Cs1, Rest)
    ;   Rest = Cs
    ).

% message_invariant(?N, ?Inv): Inv is the
% invariant of the text of message N.
message_invariant(N, Inv) :-
    text_of(N, Text),
    invariant(Text, Inv).

% prefix_of(+Prefix, ?N): the invariant of
% message N begins with Prefix.
prefix_of(Prefix, N) :-
    message_invariant(N, Inv),
    string_concat(Prefix, _, Inv).

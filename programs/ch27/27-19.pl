% 27-19.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.18 Silent Messages.
% Program block 19 of the chapter.

% silent_messages(?Inv): Inv is the invariant of a
% start message whose kind has no other message
% kind with the same stem.
silent_messages(Inv) :-
    distinct(Inv, message_invariant(_, Inv)),
    sub_string(Inv, B, _, 0, " start"),
    sub_string(Inv, 0, B, _, Stem),
    \+ ( message_invariant(_, Other),
         Other \== Inv,
         sub_string(Other, 0, _, _, Stem)
       ).

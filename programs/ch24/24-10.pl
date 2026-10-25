% 24-10.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 24. Trace Structure: 24.8 Tail of a Message Set.
% Program block 10 of the chapter.

% tail_message(Set, N): N is the last message of
% the non-empty message set Set.
tail_message(Set, N) :-
    last(Set, N).

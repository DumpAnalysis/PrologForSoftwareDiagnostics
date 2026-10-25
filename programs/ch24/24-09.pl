% 24-09.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 24. Trace Structure: 24.7 Head of a Message Set.
% Program block 9 of the chapter.

% head_message(Set, N): N is the first message of
% the non-empty message set Set.
head_message([N | _], N).

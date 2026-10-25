% 04-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 4. Clauses, Queries, and Search: 4.7 Diagnostic Use.
% Program block 6 of the chapter.

% blocked_through(TID, Other): TID is blocked by
% Other directly or through a chain of owners.
blocked_through(TID, Other) :-
    blocked_by(TID, Other).
blocked_through(TID, Other) :-
    blocked_by(TID, Owner),
    blocked_through(Owner, Other).

% 20-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 20. Synchronization Patterns: 20.4 Deadlock (Critical Sections).
% Program block 5 of the chapter.

:- table reaches/3.

% reaches(+Kind, ?A, ?B): a path of Kind edges
% leads from thread A to thread B.
reaches(Kind, A, B) :-
    edge_of(Kind, A, B).
reaches(Kind, A, B) :-
    reaches(Kind, A, C),
    edge_of(Kind, C, B).

% in_deadlock(+Kind, ?TID): TID lies on a cycle of
% Kind edges.
in_deadlock(Kind, TID) :-
    reaches(Kind, TID, TID).

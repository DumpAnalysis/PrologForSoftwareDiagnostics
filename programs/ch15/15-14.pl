% 15-14.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 15. Memory Dumps as Knowledge Bases: 15.5 Unknowns and Provenance.
% Program block 14 of the chapter.

% thread_absence(Relation, TID, Status): Status is
% present when Relation is defined and has a fact
% whose first argument is TID, absent when it has
% none and the coverage of Relation for TID is
% complete, and unknown otherwise. A relation
% that is not defined has no fact; an error raised
% by one that is defined is not caught.
thread_absence(F/A, TID, Status) :-
    (   current_predicate(F/A),
        functor(Goal, F, A),
        arg(1, Goal, TID),
        call(Goal)
    ->  Status = present
    ;   thread_coverage(F/A, TID, complete)
    ->  Status = absent
    ;   Status = unknown
    ).

% 17-02.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 17. The Pattern as a Predicate: 17.3 Evidence.
% Program block 2 of the chapter.

% holds(Term): Term is a goal that succeeds, or an
% evidence or suspicion term all of whose goals
% hold.
holds(Term) :-
    (   Term = evidence(_, _, Goals)
    ->  maplist(holds, Goals)
    ;   Term = suspected(_, _, Goals)
    ->  maplist(holds, Goals)
    ;   once(Term)
    ).

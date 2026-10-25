% 17-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 17. The Pattern as a Predicate: 17.5 Composition.
% Program block 6 of the chapter.

% leaves(Term, Goals): Goals are the goals at the
% leaves of a nested evidence term, in order; a
% goal is its own leaf.
leaves(Term, Goals) :-
    (   Term = evidence(_, _, Facts)
    ->  maplist(leaves, Facts, Lists),
        append(Lists, Goals)
    ;   Goals = [Term]
    ).

% 20-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 20. Synchronization Patterns: 20.4 Deadlock (Critical Sections).
% Program block 6 of the chapter.

% cycle_kinds(Edges, Kinds): Kinds is the set of
% kinds of the edges Edges of a witness.
cycle_kinds(Edges, Kinds) :-
    pairs_keys(Edges, Kinds0),
    sort(Kinds0, Kinds).

% deadlock_name(Kinds, Name): the catalog name of
% a deadlock whose selected edges have the set of
% kinds Kinds: the critical section variant, the
% mixed variant for two kinds or more, and the
% family name for one kind of another object.
deadlock_name([critical_section],
              'Deadlock (Critical Sections)').
deadlock_name([Kind], 'Deadlock') :-
    Kind \== critical_section.
deadlock_name([_, _ | _],
              'Deadlock (Mixed Objects)').

% deadlock(+Kind, -Cycle, -Evidence): as the test
% above; the evidence holds the facts of the edges
% the walk selected, the wait fact and the
% ownership fact of each, and the pattern is named
% from the kinds of those edges. Under a variant
% name the instance is the cycle; under the family
% name it is cycle(Kind, Cycle), so that the kind
% of object is reported.
deadlock(Kind, Cycle, Evidence) :-
    deadlock_witness(Kind, Cycle, Edges),
    cycle_kinds(Edges, Kinds),
    deadlock_name(Kinds, Name),
    (   Kinds = [One],
        One \== critical_section
    ->  Instance = cycle(One, Cycle)
    ;   Instance = Cycle
    ),
    pairs_values(Edges, Lists),
    append(Lists, Facts),
    Evidence = evidence(Name, Instance, Facts).

% 17-10.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 17. The Pattern as a Predicate: 17.7 Reports and Severity.
% Program block 10 of the chapter.

% severity(Pattern, Level): the level at which an
% instance of Pattern is reported.
severity('Deadlock (Critical Sections)',
         critical).
severity('NULL Pointer (Data)', critical).
severity('Spiking Thread', high).
severity('Handle Leak', high).
severity('Wait Chain (Critical Sections)',
         medium).
severity('Blocked Thread (Software)', medium).
severity('Frame Regularity', medium).
severity('Hooked Functions (User Space)', low).
severity('No Component Symbols', info).

% rank(Level, N): the levels in order of severity.
rank(critical, 1).
rank(high, 2).
rank(medium, 3).
rank(low, 4).
rank(info, 5).

% severity_rank(E, Rank): Rank is the rank of the
% pattern of the evidence term E.
severity_rank(evidence(Pattern, _, _), Rank) :-
    severity(Pattern, Level),
    rank(Level, Rank).

% report: print every recognized instance, grouped
% by severity, most severe first.
report :-
    pattern_instances(Evidence),
    map_list_to_pairs(severity_rank, Evidence,
                      Pairs),
    keysort(Pairs, Sorted),
    print_report(Sorted, 0).

% print_report(Pairs, Last): print the Rank-E
% pairs, with a heading whenever the rank changes
% from Last.
print_report([], _).
print_report([Rank-evidence(P, I, _) | Rest],
             Last) :-
    (   Rank == Last
    ->  true
    ;   rank(Level, Rank),
        format("~a~n", [Level])
    ),
    format("  ~a~t~33|~w~n", [P, I]),
    print_report(Rest, Rank).

% 17-07.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 17. The Pattern as a Predicate: 17.5 Composition.
% Program block 7 of the chapter.

% wait_chain(Chain, E): Chain is a list of threads
% headed by a blocked thread, each waiting for a
% critical section the next owns, ending at a
% thread that is not blocked or that repeats.
wait_chain([TID | Rest], E) :-
    blocked_on(TID, _, _),
    chain_from(TID, [TID], Rest, Facts),
    E = evidence('Wait Chain (Critical Sections)',
                 [TID | Rest], Facts).

% chain_from(TID, Seen, Rest, Facts): Rest is the
% chain of owners from TID on, stopping at an
% unblocked thread or at one in Seen.
chain_from(TID, Seen, Rest, Facts) :-
    (   blocked_on(TID, A, Owner)
    ->  critical_section(A, Owner, L, R),
        Facts = [ waits_for(TID, critical_section,
                            A),
                  critical_section(A, Owner, L, R)
                | Facts1 ],
        (   memberchk(Owner, Seen)
        ->  Rest = [Owner],
            Facts1 = []
        ;   Rest = [Owner | Rest1],
            chain_from(Owner, [Owner | Seen],
                       Rest1, Facts1)
        )
    ;   Rest = [],
        Facts = []
    ).

wait_chain(Chain) :-
    wait_chain(Chain, _).

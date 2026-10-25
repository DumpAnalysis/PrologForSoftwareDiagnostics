% 17-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 17. The Pattern as a Predicate: 17.5 Composition.
% Program block 5 of the chapter.

% blocked_on(TID, Addr, Owner): TID waits for the
% critical section at Addr, which Owner holds.
blocked_on(TID, Addr, Owner) :-
    waits_for(TID, critical_section, Addr),
    critical_section(Addr, Owner, _, _).

% blocked_thread(TID, E): TID is blocked on a
% critical section.
blocked_thread(TID, E) :-
    blocked_on(TID, Addr, Owner),
    critical_section(Addr, Owner, Lock, Rec),
    E = evidence('Blocked Thread (Software)', TID,
        [ waits_for(TID, critical_section, Addr),
          critical_section(Addr, Owner, Lock, Rec)
        ]).

blocked_thread(TID) :-
    blocked_thread(TID, _).

% deadlock(Pair, E): Pair is T1-T2, T1 < T2, each
% blocked on a section the other owns.
deadlock(T1-T2, E) :-
    blocked_on(T1, _, T2),
    blocked_on(T2, _, T1),
    T1 < T2,
    blocked_thread(T1, E1),
    blocked_thread(T2, E2),
    E = evidence('Deadlock (Critical Sections)',
                 T1-T2, [E1, E2]).

deadlock(Pair) :-
    deadlock(Pair, _).

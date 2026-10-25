% 15-09.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 15. Memory Dumps as Knowledge Bases: 15.4 Normalization.
% Program block 9 of the chapter.

% raw_fields(+Raw, -State, -Woken, -Waiters): the
% fields packed in Raw, the LockCount field of a
% critical section as Windows Server 2003 SP1 and
% later store it: bit 0 is 1 when the section is
% unlocked, bit 1 is 1 when no waiting thread has
% been woken, and the bits above are the ones'
% complement of the number of waiting threads.
% State is locked or unlocked; Woken is woken or
% none.
raw_fields(Raw, State, Woken, Waiters) :-
    must_be(integer, Raw),
    (   Raw /\ 1 =:= 1
    ->  State = unlocked
    ;   State = locked
    ),
    (   Raw /\ 2 =:= 2
    ->  Woken = none
    ;   Woken = woken
    ),
    Waiters is (-1 - Raw) >> 2,
    (   Waiters >= 0
    ->  true
    ;   domain_error(lock_count_field, Raw)
    ).

% waiters_from_raw(+Raw, -Waiters): the number of
% waiting threads encoded in Raw; the normalized
% WaiterCount of critical_section/4 for a parser
% that reads the field under this encoding.
waiters_from_raw(Raw, Waiters) :-
    raw_fields(Raw, _, _, Waiters).

% raw_from_fields(+State, +Woken, +Waiters, -Raw):
% the inverse of raw_fields/4, for checking it.
raw_from_fields(State, Woken, Waiters, Raw) :-
    (   State == unlocked -> B0 = 1 ; B0 = 0 ),
    (   Woken == none -> B1 = 1 ; B1 = 0 ),
    Raw is ((\ Waiters) << 2) \/ (B1 << 1) \/ B0.

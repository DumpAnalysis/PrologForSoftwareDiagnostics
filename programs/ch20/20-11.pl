% 20-11.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 20. Synchronization Patterns: 20.8 Critical Section Corruption.
% Program block 11 of the chapter.

% critical_section_corruption(?Addr, -Reason): the
% critical section at Addr is in an impossible
% state for Reason.
critical_section_corruption(Addr, Reason) :-
    critical_section(Addr, Owner, Waiters, Rec),
    inconsistent(Addr, Owner, Waiters, Rec,
                 Reason).

% inconsistent(Addr, Owner, Waiters, Rec, Reason):
% the fields of a critical section violate the
% rule named by Reason.
inconsistent(_, 0, _, Rec, Reason) :-
    Rec > 0,
    Reason = recursion_without_owner.
inconsistent(_, 0, Waiters, _, Reason) :-
    Waiters > 0,
    Reason = waiters_without_owner.
inconsistent(_, Owner, _, 0, Reason) :-
    Owner =\= 0,
    Reason = owner_without_recursion.
inconsistent(_, Owner, _, _, Reason) :-
    Owner =\= 0,
    \+ thread(Owner, _),
    Reason = owner_not_a_thread(Owner).
inconsistent(Addr, _, Waiters, _, Reason) :-
    aggregate_all(count,
        waits(_, critical_section, Addr), N),
    N =\= Waiters,
    Reason = waiter_count_mismatch(Waiters, N).

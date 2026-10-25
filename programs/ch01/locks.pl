% locks.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 1. Logic Programming and Diagnostics: 1.2 Facts, Rules, and Queries.
% Program block 1 of the chapter.

% owner(CS, TID): critical section CS is
% owned by thread TID.
owner(cs_a, 103).
owner(cs_b, 104).

% waits_for(TID, CS): thread TID waits to
% enter critical section CS.
waits_for(101, cs_a).
waits_for(103, cs_b).
waits_for(104, cs_a).

% blocked_by(Waiter, Owner): Waiter waits
% for a critical section that Owner owns.
blocked_by(Waiter, Owner) :-
    waits_for(Waiter, CS),
    owner(CS, Owner).

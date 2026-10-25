% 11-08.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 11. The Dynamic Database, Global State, and Tabling: 11.7 Diagnostic Use.
% Program block 8 of the chapter.

% blocked_by(Waiter, Owner): Waiter waits for a
% critical section that Owner owns.
blocked_by(Waiter, Owner) :-
    waits_for(Waiter, critical_section, Addr),
    critical_section(Addr, Owner, _, _),
    Owner \== 0.

% blocked_through(TID, Other): TID is blocked by
% Other directly or through a chain of owners.
% The definition of Chapter 4, tabled.
:- table blocked_through/2.
blocked_through(TID, Other) :-
    blocked_by(TID, Other).
blocked_through(TID, Other) :-
    blocked_by(TID, Owner),
    blocked_through(Owner, Other).

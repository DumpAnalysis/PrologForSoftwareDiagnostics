% 05-13.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 5. Lists and Recursion: 5.6 Diagnostic Use.
% Program block 13 of the chapter.

% blocked_by(Waiter, Owner): Waiter waits for a
% critical section that Owner owns.
blocked_by(Waiter, Owner) :-
    waits_for(Waiter, critical_section, Addr),
    critical_section(Addr, Owner, _, _),
    Owner \== 0.

% blocked_through(TID, Other): Other blocks TID
% directly or through a chain of owners.
blocked_through(TID, Other) :-
    blocked_through(TID, [TID], Other).

% blocked_through(TID, Visited, Other): as above,
% never passing through a thread in Visited.
blocked_through(TID, Visited, Other) :-
    blocked_by(TID, Other),
    \+ member(Other, Visited).
blocked_through(TID, Visited, Other) :-
    blocked_by(TID, Owner),
    \+ member(Owner, Visited),
    blocked_through(Owner, [Owner | Visited],
                    Other).

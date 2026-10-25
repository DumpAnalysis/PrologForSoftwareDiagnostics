% 04-07.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 4. Clauses, Queries, and Search: 4.7 Diagnostic Use.
% Program block 7 of the chapter.

% involved(TID, Addr): TID owns or waits for the
% critical section at Addr.
involved(TID, Addr) :-
    (   critical_section(Addr, TID, _, _),
        TID \== 0
    ;   waits_for(TID, critical_section, Addr)
    ).

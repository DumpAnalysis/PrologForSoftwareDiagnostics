% 04-02.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 4. Clauses, Queries, and Search: 4.4 Conjunction, Disjunction, True, and Fail.
% Program block 2 of the chapter.

% stopped(TID): the top frame of TID is in the
% report engine or in the database client.
stopped(TID) :-
    (   runs_in(TID, reportengine)
    ;   runs_in(TID, dbclient)
    ).

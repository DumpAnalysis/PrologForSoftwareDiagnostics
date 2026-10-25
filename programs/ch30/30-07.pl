% 30-07.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 30. Scale and Performance: 30.7 Tabling as Memoization.
% Program block 7 of the chapter.

:- table thread_messages/2.

% thread_messages(+TID, -Count): messages of TID.
thread_messages(TID, Count) :-
    aggregate_all(count, smsg(_, _, _, TID, _, _),
                  Count).

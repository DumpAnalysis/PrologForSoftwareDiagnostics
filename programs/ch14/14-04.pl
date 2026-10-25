% 14-04.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 14. Constraints and Coroutining: 14.4 Reconstructing an Event Order.
% Program block 4 of the chapter.

% request_order(Events): Events pairs the seven
% lifecycle events of a report request with their
% times; the constraints are those the program
% imposes on every request.
request_order([ received-R, dispatched-D,
                query_start-QS, query_end-QE,
                build_start-BS, build_end-BE,
                completed-C ]) :-
    R #< D,
    D #< QS, QS #< QE,
    D #< BS, BS #< BE,
    QE #< C, BE #< C.

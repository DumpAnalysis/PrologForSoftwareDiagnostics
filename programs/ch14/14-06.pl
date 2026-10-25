% 14-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 14. Constraints and Coroutining: 14.4 Reconstructing an Event Order.
% Program block 6 of the chapter.

% report_lifecycle(Events): request_order/1 with
% the knowledge that the build consumes the
% query's result.
report_lifecycle(Events) :-
    request_order(Events),
    memberchk(query_end-QE, Events),
    memberchk(build_start-BS, Events),
    QE #< BS.

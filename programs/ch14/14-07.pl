% 14-07.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 14. Constraints and Coroutining: 14.4 Reconstructing an Event Order.
% Program block 7 of the chapter.

% agrees(Model, Observed): every Name-Time pair of
% Observed is consistent with the Name-Var pairs
% of Model.
agrees(Model, Observed) :-
    maplist(observed_in(Model), Observed).

observed_in(Model, Event) :-
    memberchk(Event, Model).

% feasible(Observed): the observed report request
% events could have been produced by the program.
feasible(Observed) :-
    report_lifecycle(Model),
    agrees(Model, Observed).

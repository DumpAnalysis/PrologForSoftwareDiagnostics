% 14-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 14. Constraints and Coroutining: 14.4 Reconstructing an Event Order.
% Program block 5 of the chapter.

% consistent_orders(Count): Count is the number of
% total orders of the seven events that satisfy
% request_order/1.
consistent_orders(Count) :-
    request_order(Es),
    pairs_values(Es, Ps),
    Ps ins 1..7,
    all_distinct(Ps),
    findall(Ps, label(Ps), Orders),
    length(Orders, Count).

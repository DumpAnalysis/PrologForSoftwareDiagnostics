% 10-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 10. Higher-Order Predicates and Libraries: 10.3 Filtering and Partitioning.
% Program block 3 of the chapter.

% cpu_order(Threshold, TID, Order): Order is the
% order of TID's CPU time relative to Threshold.
cpu_order(Threshold, TID, Order) :-
    cpu_time(TID, Ms),
    compare(Order, Ms, Threshold).

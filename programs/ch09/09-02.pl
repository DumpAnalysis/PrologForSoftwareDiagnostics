% 09-02.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 9. Collecting Solutions and Aggregation: 9.5 Pairs and Sorting.
% Program block 2 of the chapter.

% by_count_desc(Order, K1-N1, K2-N2): order pairs
% by count descending, then by key ascending.
by_count_desc(Order, K1-N1, K2-N2) :-
    compare(Order0, N2, N1),
    (   Order0 == (=)
    ->  compare(Order, K1, K2)
    ;   Order = Order0
    ).

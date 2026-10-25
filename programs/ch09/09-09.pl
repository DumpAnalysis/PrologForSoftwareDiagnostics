% 09-09.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 9. Collecting Solutions and Aggregation: 9.6 Diagnostic Use.
% Program block 9 of the chapter.

% print_cpu_table: one row per thread, largest
% share first.
print_cpu_table :-
    forall(order_by([desc(Ms)], cpu_time(T, Ms)),
           print_cpu_row(T, Ms)).

% print_cpu_row(TID, Ms): one table row for TID.
print_cpu_row(TID, Ms) :-
    cpu_share(TID, Percent),
    format("~d~t~6|~t~D~8+ ms~3+~t~1f~8+%~n",
           [TID, Ms, Percent]).

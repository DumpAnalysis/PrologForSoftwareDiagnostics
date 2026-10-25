% 10-13.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 10. Higher-Order Predicates and Libraries: 10.9 Diagnostic Use.
% Program block 13 of the chapter.

% cpu_rows(Rows): Rows is the list of Ms-TID pairs
% of the dump, largest CPU time first.
cpu_rows(Rows) :-
    findall(Ms-TID, cpu_time(TID, Ms), Pairs),
    sort(1, @>=, Pairs, Rows).

% add_ms(Row, S0, S): S is S0 plus the CPU time
% of Row.
add_ms(Ms-_, S0, S) :-
    S is S0 + Ms.

% print_cpu_row(Total, Row, Cum0, Cum): print one
% row with its share of Total and the cumulative
% share Cum of the rows so far.
print_cpu_row(Total, Ms-TID, Cum0, Cum) :-
    Cum is Cum0 + Ms,
    Share is 100 * Ms / Total,
    CumShare is 100 * Cum / Total,
    format(
        "~d~t~5|~t~D~7+ ms~t~1f~9+%~t~1f~7+%~n",
        [TID, Ms, Share, CumShare]).

% print_cpu_shares: the CPU table with a
% cumulative share column, largest consumer first.
print_cpu_shares :-
    cpu_rows(Rows),
    foldl(add_ms, Rows, 0, Total),
    foldl(print_cpu_row(Total), Rows, 0, _).

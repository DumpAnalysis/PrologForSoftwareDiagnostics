% 17-11.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 17. The Pattern as a Predicate: 17.7 Reports and Severity.
% Program block 11 of the chapter.

% by_severity(Order, E1, E2): compare two evidence
% terms by severity rank only.
by_severity(Order, E1, E2) :-
    severity_rank(E1, R1),
    severity_rank(E2, R2),
    compare(Order, R1, R2).

% 09-07.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 9. Collecting Solutions and Aggregation: 9.6 Diagnostic Use.
% Program block 7 of the chapter.

% module_variety(Count): Count is the number of
% modules loaded in the process.
module_variety(Count) :-
    aggregate_all(count, module(_, _, _), Count).

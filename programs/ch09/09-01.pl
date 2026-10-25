% 09-01.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 9. Collecting Solutions and Aggregation: 9.1 Collecting All Solutions.
% Program block 1 of the chapter.

% event(N, TID, Kind): message N, on thread TID,
% of the given Kind.
event(1, 100, start).
event(2, 101, query).
event(3, 102, query).
event(4, 101, build).
event(5, 101, done).
event(6, 102, warning).
event(7, 102, warning).
event(8, 100, error).

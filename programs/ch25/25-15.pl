% 25-15.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 25. Time: 25.12 Significant Interval.
% Program block 15 of the chapter.

% significant_interval(N1, N2, Duration, Inside):
% Duration ms passed between messages N1 and N2,
% and Inside is the set of messages between them.
significant_interval(N1, N2, Duration, Inside) :-
    N1 < N2,
    time_ms(N1, T1),
    time_ms(N2, T2),
    Duration is T2 - T1,
    Low is N1 + 1,
    High is N2 - 1,
    (   Low =< High
    ->  numlist(Low, High, Inside)
    ;   Inside = []
    ).

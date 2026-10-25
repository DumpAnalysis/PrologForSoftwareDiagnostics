% 25-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 25. Time: 25.3 Correlated Discontinuity.
% Program block 5 of the chapter.

% correlated_discontinuity(T1-N1, T2-N2): the
% discontinuities after N1 in thread T1 and after
% N2 in thread T2 begin within the correlation
% threshold of each other.
correlated_discontinuity(T1-N1, T2-N2) :-
    thread_discontinuity(T1, N1, _),
    thread_discontinuity(T2, N2, _),
    T1 @< T2,
    time_ms(N1, S1),
    time_ms(N2, S2),
    threshold(correlation, Max),
    abs(S1 - S2) =< Max.

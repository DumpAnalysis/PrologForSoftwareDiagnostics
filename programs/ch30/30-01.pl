% 30-01.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 30. Scale and Performance: 30.1 Measuring.
% Program block 1 of the chapter.

:- [trace1].

% threshold(Pattern, Value)
threshold(discontinuity, 1.0).

% slow_discontinuity(?N, -Gap): pairs of messages,
% then a test. Quadratic in the trace length.
slow_discontinuity(N1, Gap) :-
    msg(N1, T1, _, _, _, _),
    msg(N2, T2, _, _, _, _),
    N2 =:= N1 + 1,
    Gap is T2 - T1,
    threshold(discontinuity, Min),
    Gap > Min.

% discontinuity(?N, -Gap): the next message is
% looked up by number. Linear in the trace length.
discontinuity(N1, Gap) :-
    msg(N1, T1, _, _, _, _),
    N2 is N1 + 1,
    msg(N2, T2, _, _, _, _),
    Gap is T2 - T1,
    threshold(discontinuity, Min),
    Gap > Min.

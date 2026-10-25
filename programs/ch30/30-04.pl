% 30-04.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 30. Scale and Performance: 30.4 Discontinuity at Scale.
% Program block 4 of the chapter.

% big_discontinuity(?N, -Gap): Discontinuity over
% the synthetic trace.
big_discontinuity(N1, Gap) :-
    smsg(N1, T1, _, _, _, _),
    N2 is N1 + 1,
    smsg(N2, T2, _, _, _, _),
    Gap is T2 - T1,
    threshold(discontinuity, Min),
    Gap > Min.

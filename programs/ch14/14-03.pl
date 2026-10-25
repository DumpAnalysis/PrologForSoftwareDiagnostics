% 14-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 14. Constraints and Coroutining: 14.3 Global Constraints and Reification.
% Program block 3 of the chapter.

% at_most(Max, Threshold, Values): at most Max of
% Values exceed Threshold.
at_most(Max, Threshold, Values) :-
    maplist(exceeds_flag(Threshold), Values,
            Flags),
    sum(Flags, #=<, Max).

exceeds_flag(Threshold, Value, Flag) :-
    Flag #<==> (Value #> Threshold).

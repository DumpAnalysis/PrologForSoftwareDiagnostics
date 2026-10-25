% 14-14.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 14. Constraints and Coroutining: 14.7 Diagnostic Use.
% Program block 14 of the chapter.

% relative_order(Text, N, Order): under every
% admissible skew, the dblog message Text is
% before or after application message N;
% undetermined if the skew interval allows both.
relative_order(Text, N, Order) :-
    dblog(Tdb, _, Text),
    app_msg(N, Tapp),
    (   \+ ( skew(S), Tdb - S #>= Tapp )
    ->  Order = before
    ;   \+ ( skew(S), Tdb - S #=< Tapp )
    ->  Order = after
    ;   Order = undetermined
    ).

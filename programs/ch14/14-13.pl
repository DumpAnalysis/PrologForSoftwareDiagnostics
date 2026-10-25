% 14-13.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 14. Constraints and Coroutining: 14.7 Diagnostic Use.
% Program block 13 of the chapter.

% link(Order, Text, N): the dblog message Text
% happened before or after application message N.
link(after,  "Connecting to db01:5432", 2).
link(before, "Connected to db01:5432, session=71",
     6).
link(after,  "Query start: SELECT report 17", 11).
link(before, "Query end: 1 row, 44 ms", 17).
link(after,  "Query start: SELECT report 19", 37).
link(before, "Query end: 1 row, 53 ms", 58).

% skew(S): S is the offset in ms of the database
% client's clock: its time is the application's
% time plus S.
skew(S) :-
    findall(Order-(Tdb, Tapp),
            ( link(Order, Text, N),
              dblog(Tdb, _, Text),
              app_msg(N, Tapp) ),
            Links),
    maplist(skew_link(S), Links).

skew_link(S, after-(Tdb, Tapp)) :-
    Tdb - S #> Tapp.
skew_link(S, before-(Tdb, Tapp)) :-
    Tdb - S #< Tapp.

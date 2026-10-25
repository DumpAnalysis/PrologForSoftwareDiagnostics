% 14-12.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 14. Constraints and Coroutining: 14.7 Diagnostic Use.
% Program block 12 of the chapter.

% dblog(Time, TID, Text): the database client's
% own log of the same run; Time in ms of its own
% clock.
dblog(1265, 100, "Connecting to db01:5432").
dblog(1462, 100,
      "Connected to db01:5432, session=71").
dblog(2254, 101, "Query start: SELECT report 17").
dblog(2298, 101, "Query end: 1 row, 44 ms").
dblog(2752, 102, "Query start: SELECT report 18").
dblog(2800, 102, "Query end: 1 row, 48 ms").
dblog(3253, 103,
      "Send start: session=71, bytes=1024").
dblog(3352, 104,
      "Reply received: session=71, bytes=512").
dblog(10257, 101,
      "Query start: SELECT report 19").
dblog(10310, 101, "Query end: 1 row, 53 ms").
dblog(15251, 109, "Receive start: session=71").
dblog(15252, 109,
      "Error: buffer copy failed, code=0x3e6").

% app_msg(N, Ms): message N of the application
% log, at Ms milliseconds of the application's
% clock.
app_msg(N, Ms) :-
    msg(N, Time, _, _, Component, _),
    Component \== dbclient,
    ms(Time, Ms).

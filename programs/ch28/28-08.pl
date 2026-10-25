% 28-08.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 28. Sequences, Motifs, and Correlation: 28.7 Split Trace and Master Trace.
% Program block 8 of the chapter.

:- multifile msg/7.

% trace a: the appserver log alone.
msg(a, 1, 0.000, 4120, 100, appserver,
    "Service starting, version 3.2.1.0").
msg(a, 2, 1.002, 4120, 100, appserver,
    "Request 1 received: GET /report/17").
msg(a, 3, 1.311, 4120, 101, appserver,
    "Request 1 completed: 200, 309 ms").
msg(a, 4, 14.010, 4120, 100, appserver,
    "Service stopping").

% trace b: the dbclient log, same run.
msg(b, 1, 0.115, 4120, 100, dbclient,
    "Connecting to db01:5432").
msg(b, 2, 0.312, 4120, 100, dbclient,
    "Connected to db01:5432, session=71").
msg(b, 3, 1.104, 4120, 101, dbclient,
    "Query start: SELECT report 17").
msg(b, 4, 14.102, 4120, 109, dbclient,
    "Error: copy failed, code=0x3e6").

% trace_source(?T): a split trace to be merged.
trace_source(a).
trace_source(b).

% master_trace(-Rows): the split traces merged
% into one time-ordered list of row/5 terms.
master_trace(Rows) :-
    findall(row(Time, T, N, TID, Text),
            ( trace_source(T),
              msg(T, N, Time, _, TID, _, Text)
            ),
            Rows0),
    predsort(by_time, Rows0, Rows).

% by_time(-Order, +Row1, +Row2): order rows by
% time, breaking ties by trace then number so
% that no two distinct rows compare equal.
by_time(Order, row(T1, Tr1, N1, _, _),
               row(T2, Tr2, N2, _, _)) :-
    (   compare(O0, T1, T2), O0 \== (=)
    ->  Order = O0
    ;   compare(O1, Tr1, Tr2), O1 \== (=)
    ->  Order = O1
    ;   compare(Order, N1, N2)
    ).

% print_master(+Rows): one line per merged row.
print_master(Rows) :-
    forall(member(row(Time, T, N, TID, Text),
                  Rows),
           format("~3f ~a~d ~d ~s~n",
                  [Time, T, N, TID, Text])).

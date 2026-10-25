% 12-10.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 12. Definite Clause Grammars: 12.7 Grammars over Files.
% Program block 10 of the chapter.

% sample_log_line(Line): a line of the sample log.
sample_log_line(
    "2026-10-03 12:00:01.234 [4120:0100] \c
     appserver: Service starting").
sample_log_line(
    "2026-10-03 12:00:01.235 [4120:0101] \c
     appserver: Worker 101 ready").
sample_log_line(
    "2026-10-03 12:00:02.000 [4120:0101] \c
     dbclient: Query start: 17").
sample_log_line(
    "2026-10-03 12:00:02.044 [4120:0101] \c
     dbclient: Query end: 44 ms").
sample_log_line(
    "2026-10-03 12:00:07.002 [4120:0100] \c
     appserver: Error: no worker").
sample_log_line(
    "2026-10-03 12:00:09.301 [4120:0101] \c
     appserver: Request 5 done").

% write_sample_log(File): write the sample log to
% File, one line per sample_log_line/1 fact.
write_sample_log(File) :-
    setup_call_cleanup(
        open(File, write, Out),
        forall(sample_log_line(Line),
               format(Out, "~s~n", [Line])),
        close(Out)).

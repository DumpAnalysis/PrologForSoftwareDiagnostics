% 12-08.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 12. Definite Clause Grammars: 12.6 A Log Line.
% Program block 8 of the chapter.

% date(date(Y, M, D)): a date as YYYY-MM-DD.
date(date(Y, M, D)) -->
    integer(Y), "-", integer(M), "-", integer(D).

% time_of_day(T): HH:MM:SS.mmm as seconds since
% midnight.
time_of_day(T) -->
    integer(H), ":", integer(Mi), ":", number(S),
    { T is H * 3600 + Mi * 60 + S }.

% log_line(N, Msg): one line of the log, as the
% msg/6 term with ordinal number N.
log_line(N, Msg) -->
    date(_), " ",
    time_of_day(Time), " [",
    integer(PID), ":", integer(TID), "] ",
    string_without(":", CC), ": ",
    string_without("\n", TC),
    { atom_codes(Comp, CC),
      string_codes(Text, TC),
      Msg = msg(N, Time, PID, TID, Comp, Text)
    }.

% sample_msg(Line): one log line as a string.
sample_msg("2026-10-03 12:00:01.234 [4120:0101] \c
            appserver: Request 1 received").

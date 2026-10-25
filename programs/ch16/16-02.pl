% 16-02.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 16. Software Traces and Logs as Knowledge Bases: 16.3 Loading a Text Log.
% Program block 2 of the chapter.

% log_parts(Parts): the pieces of one log line.
log_parts(["2026-10-03 12:00:00.215 [4120:0101] ",
           "appserver: ", "Worker 101 ready"]).
log_parts(["2026-10-03 12:00:00.215 [4120:0102] ",
           "appserver: ", "Worker 102 ready"]).
log_parts(["2026-10-03 12:00:00.216 [4120:0103] ",
           "appserver: ", "Worker 103 ready"]).
log_parts(["2026-10-03 12:00:00.216 [4120:0104] ",
           "appserver: ", "Worker 104 ready"]).

% log_line(Line): Line is one line of the sample
% log, as a string.
log_line(Line) :-
    log_parts(Parts),
    atomics_to_string(Parts, Line).

% parse_line(Line, M): M is the m/5 term for Line.
parse_line(Line, m(Ms, PID, TID, C, Text)) :-
    string_codes(Line, Codes),
    phrase(log_line(Ms, PID, TID, C, Text),
           Codes).

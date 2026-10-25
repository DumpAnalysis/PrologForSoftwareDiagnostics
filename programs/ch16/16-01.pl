% 16-01.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 16. Software Traces and Logs as Knowledge Bases: 16.3 Loading a Text Log.
% Program block 1 of the chapter.

:- use_module(library(dcg/basics)).

% log_line(Ms, PID, TID, Component, Text)//: one
% line of the log format; Ms is the clock time in
% milliseconds since midnight.
log_line(Ms, PID, TID, Component, Text) -->
    date, " ", clock(Ms), " [",
    integer(PID), ":", integer(TID), "] ",
    string_without(":", CC), ": ",
    remainder(TC),
    { atom_codes(Component, CC),
      string_codes(Text, TC) }.

% date//: a date, read and discarded.
date -->
    digits(_), "-", digits(_), "-", digits(_).

% clock(Ms)//: hh:mm:ss.fff as milliseconds.
clock(Ms) -->
    integer(H), ":", integer(M), ":", integer(S),
    ".", digits(FC),
    { number_codes(F, FC),
      Ms is ((H * 60 + M) * 60 + S) * 1000 + F }.

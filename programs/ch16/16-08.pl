% 16-08.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 16. Software Traces and Logs as Knowledge Bases: 16.8 Several Traces in One Knowledge Base.
% Program block 8 of the chapter.

% msg(Trace, N, Time, PID, TID, Component, Text):
% the message N of the trace named Trace.
msg(trace1, N, Time, PID, TID, Component, Text) :-
    msg(N, Time, PID, TID, Component, Text).

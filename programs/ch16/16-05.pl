% 16-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 16. Software Traces and Logs as Knowledge Bases: 16.5 Loading and Saving CSV.
% Program block 5 of the chapter.

% message_row(Row): Row is a row/6 term for a
% message of the trace.
message_row(row(N, T, P, TID, C, Text)) :-
    msg(N, T, P, TID, C, Text).

% row_message(Row, Msg): Msg is the msg/6 term for
% the row/6 term Row read from a CSV file.
row_message(row(N, T, P, TID, C, Text0), Msg) :-
    atom_string(Text0, Text),
    Msg = msg(N, T, P, TID, C, Text).

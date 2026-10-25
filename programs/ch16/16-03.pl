% 16-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 16. Software Traces and Logs as Knowledge Bases: 16.3 Loading a Text Log.
% Program block 3 of the chapter.

% log_messages(Lines, Msgs): Msgs are the msg/6
% terms for the log lines Lines, numbered from 1,
% with Time in seconds from the first message.
log_messages(Lines, Msgs) :-
    maplist(parse_line, Lines, Parsed),
    Parsed = [m(Ms0, _, _, _, _) | _],
    foldl(number_message(Ms0), Parsed, Msgs,
          1, _).

% number_message(Ms0, M, Msg, N, N1): Msg is the
% msg/6 term numbered N for the m/5 term M, with
% Time relative to Ms0; N1 is the next number.
number_message(Ms0, m(Ms, PID, TID, C, Text), Msg,
               N, N1) :-
    Time is (Ms - Ms0) / 1000.0,
    Msg = msg(N, Time, PID, TID, C, Text),
    N1 is N + 1.

% write_facts(File, Facts): write Facts to File as
% clauses, one per line.
write_facts(File, Facts) :-
    setup_call_cleanup(
        open(File, write, S),
        maplist(portray_clause(S), Facts),
        close(S)).

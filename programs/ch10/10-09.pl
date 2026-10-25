% 10-09.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 10. Higher-Order Predicates and Libraries: 10.7 Dicts.
% Program block 9 of the chapter.

% thread_record(TID, Record): Record is a dict
% with the identifier, state, and CPU time of TID.
thread_record(TID, Record) :-
    Record = thread{tid: TID, state: S, cpu: Ms},
    thread_state(TID, S),
    cpu_time(TID, Ms).

% busy(Record): the thread consumed more than a
% second of CPU time.
busy(Record) :-
    Record.cpu > 1000.

% record_state(Record, State): State is the state
% field of Record.
record_state(Record, State) :-
    State = Record.state.

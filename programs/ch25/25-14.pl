% 25-14.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 25. Time: 25.11 Timeout.
% Program block 14 of the chapter.

% timeout_value(Name, Ms): a configured timeout.
timeout_value(health_check, 1000).
timeout_value(worker_wait, 7000).

% near_timeout(Ms, Name): Ms is within tolerance
% of the timeout Name.
near_timeout(Ms, Name) :-
    timeout_value(Name, Value),
    threshold(timeout_tolerance, Tolerance),
    abs(Ms - Value) =< Tolerance.

% timeout(N, Name): message N reports a duration
% matching the timeout Name.
timeout(N, Name) :-
    reported_duration(N, Ms),
    near_timeout(Ms, Name).

% timeout(N, Next, Name): Next is the next message
% of the kind of N, and the delta between them
% matches the timeout Name.
timeout(N, Next, Name) :-
    msg(N, _, _, _, _, _),
    message_kind(N, Kind),
    kind_messages(Kind, Set),
    time_delta(Set, N, Next, Delta),
    near_timeout(Delta, Name).

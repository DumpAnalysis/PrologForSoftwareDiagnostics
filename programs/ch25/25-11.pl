% 25-11.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 25. Time: 25.8 Delay Dynamics.
% Program block 11 of the chapter.

% completion(N, Request, Ms): message N reports
% the completion of Request in Ms milliseconds.
completion(N, Request, Ms) :-
    msg(N, _, _, _, _, Text),
    string_codes(Text, Codes),
    phrase(completion(Request, Ms), Codes).

completion(Request, Ms) -->
    "Request ", integer(Request),
    " completed: ", integer(_Status),
    ", ", integer(Ms), " ms".

% reported_duration(N, Ms): the text of message N
% ends with a duration of Ms milliseconds.
reported_duration(N, Ms) :-
    msg(N, _, _, _, _, Text),
    string_concat(Front, " ms", Text),
    split_string(Front, " ", "", Parts),
    last(Parts, Last),
    number_string(Ms, Last).

% delay_dynamics(Durations, Changes): Durations is
% the list of completion times in trace order and
% Changes their successive differences.
delay_dynamics(Durations, Changes) :-
    findall(Ms, completion(_, _, Ms), Durations),
    changes(Durations, Changes).

changes([], []).
changes([X | Xs], Changes) :-
    changes_from(Xs, X, Changes).

changes_from([], _, []).
changes_from([Y | Ys], X, [D | Ds]) :-
    D is Y - X,
    changes_from(Ys, Y, Ds).

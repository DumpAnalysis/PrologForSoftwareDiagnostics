% 12-11.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 12. Definite Clause Grammars: 12.7 Grammars over Files.
% Program block 11 of the chapter.

% msg(N, Time, PID, TID, Component, Text): the
% schema relation, filled from a parsed log.
:- dynamic msg/6.

% load_log(File): parse File and assert its
% messages as msg/6 facts.
load_log(File) :-
    phrase_from_file(log_lines(1, Msgs), File),
    maplist(assertz, Msgs).

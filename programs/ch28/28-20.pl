% 28-20.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 28. Sequences, Motifs, and Correlation: 28.17 Small DA+TA.
% Program block 20 of the chapter.

% housekeeping_wait(-TID, -Ms): the watchdog
% reported worker TID waiting Ms milliseconds.
housekeeping_wait(TID, Ms) :-
    msg(_, _, _, 108, _, Text),
    split_string(Text, " ", "", Words),
    nth1(3, Words, WTID),
    number_string(TID, WTID),
    nth1(5, Words, WMs),
    number_string(Ms, WMs).

% deadlock_corroborated(-TID, -Ms, -Addr): a
% worker the watchdog reported waiting is, in
% the dump, blocked on critical section Addr.
deadlock_corroborated(TID, Ms, Addr) :-
    housekeeping_wait(TID, Ms),
    waits_for(TID, critical_section, Addr).

% 28-21.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 28. Sequences, Motifs, and Correlation: 28.17 Small DA+TA.
% Program block 21 of the chapter.

% spiking_corroborated(-TID, -Ms): a worker the
% watchdog reported at full CPU has high CPU time
% in the dump.
spiking_corroborated(TID, Ms) :-
    msg(_, _, _, 108, _, Text),
    sub_string(Text, _, _, _, "cpu 100%"),
    split_string(Text, " ", "", Words),
    nth1(3, Words, WTID),
    number_string(TID, WTID),
    thread_time(TID, User, Kernel),
    Ms is User + Kernel.

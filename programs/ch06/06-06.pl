% 06-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 6. Arithmetic: 6.7 Diagnostic Use.
% Program block 6 of the chapter.

% spiking_threshold(Percent): a thread whose share
% of the CPU time is at least Percent is spiking.
spiking_threshold(25).

% spiking_thread(TID): TID has consumed at least
% the threshold share of the process CPU time.
spiking_thread(TID) :-
    cpu_share(TID, Percent),
    spiking_threshold(Threshold),
    Percent >= Threshold.

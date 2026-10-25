% 26-10.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 26. Activities and Threads of Activity: 26.9 Coupled Activities.
% Program block 10 of the chapter.

% coupled_activities(T1, T2, N1-N2): message N2 of
% thread T2 follows message N1 of thread T1 within
% the coupling threshold.
coupled_activities(T1, T2, N1-N2) :-
    msg(N1, Time1, _, T1, _, _),
    N2 is N1 + 1,
    msg(N2, Time2, _, T2, _, _),
    T1 \== T2,
    threshold(coupling, Max),
    round((Time2 - Time1) * 1000) =< Max.

% print_couplings: one line per hand-off.
print_couplings :-
    forall(coupled_activities(T1, T2, N1-N2),
           print_coupling(T1, T2, N1, N2)).

print_coupling(T1, T2, N1, N2) :-
    format("~t~d~3| -> ~d~t~12|~t~d~16|-~d~n",
           [T1, T2, N1, N2]).

% 30-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 30. Scale and Performance: 30.3 A Synthetic Trace.
% Program block 3 of the chapter.

:- dynamic smsg/6.

% gen_trace(+N): assert N synthetic messages.
gen_trace(N) :-
    retractall(smsg(_, _, _, _, _, _)),
    forall(between(1, N, I),
           ( Ms is I + 2000 * (I // 1000),
             T is Ms / 1000.0,
             TID is 100 + I mod 5,
             component(I, C),
             assertz(smsg(I, T, 4120, TID, C,
                          "Request")) )).

component(I, C) :-
    K is I mod 3,
    nth0(K, [appserver, dbclient, reportengine],
         C).

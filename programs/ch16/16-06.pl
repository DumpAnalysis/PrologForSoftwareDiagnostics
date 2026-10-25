% 16-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 16. Software Traces and Logs as Knowledge Bases: 16.6 Derived Relations.
% Program block 6 of the chapter.

% delta(N1, N2, Delta): N2 is the message after N1
% in the trace and Delta the seconds between them.
delta(N1, N2, Delta) :-
    msg(N1, T1, _, _, _, _),
    N2 is N1 + 1,
    msg(N2, T2, _, _, _, _),
    Delta is T2 - T1.

% thread_messages(TID, Ns): Ns is the ordered list
% of the numbers of the messages written by TID.
thread_messages(TID, Ns) :-
    setof(N,
          T^P^C^Text^msg(N, T, P, TID, C, Text),
          Ns).

% component_messages(Component, Ns): Ns is the
% ordered list of the numbers of the messages of
% Component.
component_messages(Component, Ns) :-
    setof(N,
          T^P^TID^Text^msg(N, T, P, TID,
                           Component, Text),
          Ns).

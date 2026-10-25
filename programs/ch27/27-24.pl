% 27-24.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.22 Diegetic Messages.
% Program block 24 of the chapter.

% non_diegetic_component(?C): component C writes
% about the trace, not from within the software.
non_diegetic_component(tracer).
non_diegetic_component(tester).

% diegetic_messages(+Trace, -Ns): the messages of
% Trace written by the software itself.
diegetic_messages(T, Ns) :-
    findall(N,
            ( trace_text(T, N, _, C, _),
              \+ non_diegetic_component(C)
            ),
            Ns).

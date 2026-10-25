% 14-10.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 14. Constraints and Coroutining: 14.5 Deducing a Counter.
% Program block 10 of the chapter.

% depth_model(Events, D0, Final, Incs): D0 is the
% queue depth before Events and Final after them;
% Incs pairs each received request with its
% increment, 1 if it was queued.
depth_model(Events, D0, Final, Incs) :-
    D0 #>= 0,
    findall(R, member(queued(R), Events), Queued),
    depth_steps(Events, Queued, D0, Final,
                [], Incs).

depth_steps([], _, D, D, Incs, Incs).
depth_steps([E | Es], Qd, D0, D, Incs0, Incs) :-
    depth_step(E, Qd, D0, D1, Incs0, Incs1),
    depth_steps(Es, Qd, D1, D, Incs1, Incs).

depth_step(received(R), Queued, D0, D1,
           Incs, [R-I | Incs]) :-
    (   memberchk(R, Queued)
    ->  I = 1
    ;   I in 0..1
    ),
    D1 #= D0 + I.
depth_step(queued(_), _, D, D, Incs, Incs).
depth_step(depth(V), _, D, D, Incs, Incs) :-
    D #= V.
depth_step(dispatched(R), _, D0, D1, Incs,
           Incs) :-
    memberchk(R-I, Incs),
    D1 #= D0 - I,
    D1 #>= 0.

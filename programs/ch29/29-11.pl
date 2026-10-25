% 29-11.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 29. Meta-Interpreters and Explanation: 29.9 Certainty Factors.
% Program block 11 of the chapter.

% frame_regularity(?TID): the top four frames
% repeat one function.
frame_regularity(TID) :-
    frame(TID, 0, M, F, _),
    frame(TID, 1, M, F, _),
    frame(TID, 2, M, F, _),
    frame(TID, 3, M, F, _).

% rule(Hypothesis, Condition, Weight)
rule(suspect(T, stack_overflow),
     frame_regularity(T), 0.3).
rule(suspect(T, stack_overflow),
     ( frame_regularity(T),
       exception_record(T, 0xc00000fd, _) ),
     0.95).
rule(suspect(T, infinite_loop),
     spiking_thread(T), 0.6).
rule(suspect(T, infinite_loop),
     ( spiking_thread(T),
       thread_state(T, running) ), 0.8).

% solve_cf(+Goal, -CF): Goal holds with
% certainty CF.
solve_cf(true, 1.0).
solve_cf((A, B), CF) :-
    solve_cf(A, CA),
    solve_cf(B, CB),
    CF is min(CA, CB).
solve_cf(G, CF) :-
    \+ control(G),
    (   \+ rule(G, _, _)
    ->  solve(G),
        CF = 1.0
    ;   rule(G, Condition, Weight),
        solve_cf(Condition, CC),
        CF is CC * Weight
    ).

% certainty(+Hypothesis, -CF): the best certainty
% any rule gives Hypothesis; fails if none does.
certainty(H, CF) :-
    aggregate_all(max(C), solve_cf(H, C), CF).

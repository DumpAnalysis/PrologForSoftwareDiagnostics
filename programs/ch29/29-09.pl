% 29-09.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 29. Meta-Interpreters and Explanation: 29.7 Counting Inferences.
% Program block 9 of the chapter.

% solve_count(+Goal, -N): N is the number of goals
% resolved in the proof of Goal that was found.
solve_count(G, N) :-
    solve_count(G, 0, N).

solve_count(true, N, N).
solve_count((A, B), N0, N) :-
    solve_count(A, N0, N1),
    solve_count(B, N1, N).
solve_count(\+ A, N0, N) :-
    \+ solve_count(A, 0, _),
    N is N0 + 1.
solve_count(G, N0, N) :-
    \+ control(G),
    N1 is N0 + 1,
    (   system_goal(G)
    ->  call(G),
        N = N1
    ;   clause(G, Body),
        solve_count(Body, N1, N)
    ).

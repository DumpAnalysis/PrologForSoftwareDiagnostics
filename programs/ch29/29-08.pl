% 29-08.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 29. Meta-Interpreters and Explanation: 29.6 Depth-Bounded Interpretation.
% Program block 8 of the chapter.

% solve_depth(+Goal, +Depth): Goal has a proof in
% which no branch uses more than Depth clauses.
solve_depth(true, _).
solve_depth((A, B), D) :-
    solve_depth(A, D),
    solve_depth(B, D).
solve_depth(\+ A, D) :-
    \+ solve_depth(A, D).
solve_depth(G, D) :-
    \+ control(G),
    (   system_goal(G)
    ->  call(G)
    ;   D > 0,
        D1 is D - 1,
        clause(G, Body),
        solve_depth(Body, D1)
    ).

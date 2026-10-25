% 29-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 29. Meta-Interpreters and Explanation: 29.3 Proof Trees.
% Program block 3 of the chapter.

% solve(+Goal, -Proof): Proof is a proof tree of
% Goal.
solve(G, proof(G, Subs)) :-
    \+ control(G),
    (   collecting(G)
    ->  collect(G, Subs)
    ;   system_goal(G)
    ->  call(G),
        Subs = []
    ;   clause(G, Body),
        solve_body(Body, Subs)
    ).

% collect(+Goal, -Subs): Goal is a collecting goal
% whose inner goal has the proofs Subs, one per
% solution; the collected result is computed from
% the solutions as the goal itself computes it.
collect(findall(T, G, L), Subs) :-
    findall(T-P, solve(G, P), Pairs),
    pairs_keys_values(Pairs, L, Subs).
collect(aggregate_all(Spec, G, R), Subs) :-
    findall(Spec-P, solve(G, P), Pairs),
    pairs_keys_values(Pairs, Specs, Subs),
    aggregate_all(Spec, member(Spec, Specs), R).

% solve_body(+Body, -Proofs): Proofs is the list
% of proof trees of the goals of Body.
solve_body(true, []).
solve_body((A, B), Proofs) :-
    solve_body(A, PA),
    solve_body(B, PB),
    append(PA, PB, Proofs).
solve_body((If -> Then ; Else), Proofs) :-
    (   solve_body(If, PI)
    ->  solve_body(Then, PT),
        append(PI, PT, Proofs)
    ;   solve_body(Else, Proofs)
    ).
solve_body((A ; B), Proofs) :-
    A \= (_ -> _),
    (   solve_body(A, Proofs)
    ;   solve_body(B, Proofs)
    ).
solve_body(\+ A, [proof(\+ A, [])]) :-
    \+ solve_body(A, _).
solve_body(G, [Proof]) :-
    \+ control(G),
    solve(G, Proof).

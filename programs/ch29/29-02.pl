% 29-02.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 29. Meta-Interpreters and Explanation: 29.2 The Vanilla Meta-Interpreter.
% Program block 2 of the chapter.

% solve(+Goal): Goal is provable from the program,
% by interpretation of its clauses.
solve(true).
solve((A, B)) :-
    solve(A),
    solve(B).
solve((If -> Then ; Else)) :-
    (   solve(If)
    ->  solve(Then)
    ;   solve(Else)
    ).
solve((A ; B)) :-
    A \= (_ -> _),
    (   solve(A)
    ;   solve(B)
    ).
solve(\+ A) :-
    \+ solve(A).
solve(findall(T, G, L)) :-
    findall(T, solve(G), L).
solve(aggregate_all(Spec, G, R)) :-
    aggregate_all(Spec, solve(G), R).
solve(G) :-
    \+ control(G),
    \+ collecting(G),
    (   system_goal(G)
    ->  call(G)
    ;   clause(G, Body),
        solve(Body)
    ).

% control(@Goal): Goal is a control construct that
% solve/1 handles by a clause of its own.
control(true).
control((_, _)).
control((_ ; _)).
control(\+ _).

% collecting(@Goal): Goal collects the solutions
% of an inner goal, which solve/1 interprets.
collecting(findall(_, _, _)).
collecting(aggregate_all(_, _, _)).

% system_goal(+Goal): Goal is executed by the
% system, not interpreted: a built-in or a
% predicate of a library module.
system_goal(G) :-
    predicate_property(G, built_in).
system_goal(G) :-
    predicate_property(G, imported_from(M)),
    module_property(M, class(library)).

% 29-10.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 29. Meta-Interpreters and Explanation: 29.8 A Tracing Meta-Interpreter.
% Program block 10 of the chapter.

% trace_solve(+Goal): solve Goal, printing the
% four ports of each goal, indented by depth.
trace_solve(G) :-
    trace_goal(G, 0).

trace_goal(true, _).
trace_goal((A, B), D) :-
    trace_goal(A, D),
    trace_goal(B, D).
trace_goal(\+ A, D) :-
    \+ trace_goal(A, D).
trace_goal(G, D) :-
    \+ control(G),
    port(call, D, G),
    (   step(G, D),
        (   port(exit, D, G)
        ;   port(redo, D, G),
            fail
        )
    ;   port(fail, D, G),
        fail
    ).

% step(+Goal, +Depth): one resolution step.
step(G, D) :-
    (   system_goal(G)
    ->  call(G)
    ;   clause(G, Body),
        D1 is D + 1,
        trace_goal(Body, D1)
    ).

port(Port, Depth, G) :-
    Indent is Depth * 2,
    \+ \+ ( numbervars(G, 0, _,
                       [singletons(true)]),
            format("~t~*|~a ~p~n",
                   [Indent, Port, G]) ).

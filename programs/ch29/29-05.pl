% 29-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 29. Meta-Interpreters and Explanation: 29.4 Printing Proofs as Explanations.
% Program block 5 of the chapter.

% why(+Goal): print a proof of Goal as an indented
% explanation; one answer per proof.
why(G) :-
    solve(G, Proof),
    print_proof(Proof, 0).

print_proof(proof(G, Subs), Depth) :-
    Indent is Depth * 2,
    \+ \+ ( numbervars(G, 0, _,
                       [singletons(true)]),
            format("~t~*|~p", [Indent, G]) ),
    (   Subs == []
    ->  (   leaf_fact(G)
        ->  nl
        ;   format(" holds~n")
        )
    ;   format(" because~n"),
        Deeper is Depth + 1,
        forall(member(Sub, Subs),
               print_proof(Sub, Deeper))
    ).

% leaf_fact(+Goal): a leaf that is a fact of the
% knowledge base, not a built-in or a negation.
leaf_fact(G) :-
    G \= (\+ _),
    \+ system_goal(G).

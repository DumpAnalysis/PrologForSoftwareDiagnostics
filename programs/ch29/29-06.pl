% 29-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 29. Meta-Interpreters and Explanation: 29.5 Evidence from Proofs.
% Program block 6 of the chapter.

% pattern_name(Functor, Name): the catalog name of
% the pattern the recognizer Functor recognizes.
pattern_name(blocked_thread,
             'Blocked Thread (Software)').
pattern_name(deadlock,
             'Deadlock (Critical Sections)').
pattern_name(spiking_thread, 'Spiking Thread').
pattern_name(handle_leak, 'Handle Leak').

% proof_facts(+Proof, -Facts): the facts of the
% knowledge base among the leaves of Proof.
proof_facts(proof(G, []), Facts) :-
    (   leaf_fact(G)
    ->  Facts = [G]
    ;   Facts = []
    ).
proof_facts(proof(_, [Sub|Subs]), Facts) :-
    maplist(proof_facts, [Sub|Subs], Lists),
    append(Lists, Facts).

% evidence(+Goal, -Evidence): Evidence is
% evidence(Pattern, Instance, Facts) for one proof
% of the recognizer goal Goal: Pattern its catalog
% name, Instance its argument or its two arguments
% as a pair, Facts the facts of the proof, once.
evidence(Goal, Evidence) :-
    Evidence = evidence(Pattern, Instance, Facts),
    solve(Goal, Proof),
    Goal =.. [Functor | Args],
    pattern_name(Functor, Pattern),
    instance_of(Args, Instance),
    proof_facts(Proof, Facts0),
    list_to_set(Facts0, Facts).

instance_of([Instance], Instance).
instance_of([A, B], A-B).

% print_evidence(+Goal): one line per fact.
print_evidence(Goal) :-
    evidence(Goal, evidence(P, I, Facts)),
    format("~a: ~p~n", [P, I]),
    forall(member(F, Facts),
           format("  ~p~n", [F])).

% 31-08.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 31. Integration: Scripts, Embedding, and Debugger Extensions: 31.9 Prolog as a Verifier for LLM-Based Agents.
% Program block 8 of the chapter; loaded fresh.

:- [dump1].
:- use_module(patterns_dump).
:- use_module(library(http/json)).
:- use_module(library(sandbox)).

% prove(+Module, +Goal, -Facts): Goal, called in
% Module, has a proof that used the facts Facts.
prove(_, true, []).
prove(M, (A, B), Facts) :-
    prove(M, A, FA),
    prove(M, B, FB),
    append(FA, FB, Facts).
prove(M, (If -> Then ; Else), Facts) :-
    (   prove(M, If, FI)
    ->  prove(M, Then, FT),
        append(FI, FT, Facts)
    ;   prove(M, Else, Facts)
    ).
prove(M, (A ; B), Facts) :-
    A \= (_ -> _),
    (   prove(M, A, Facts)
    ;   prove(M, B, Facts)
    ).
prove(M, \+ A, []) :-
    \+ prove(M, A, _).
prove(M, once(A), Facts) :-
    once(prove(M, A, Facts)).
prove(M, findall(T, G, L), Facts) :-
    findall(T-F, prove(M, G, F), Pairs),
    pairs_keys_values(Pairs, L, Lists),
    append(Lists, Facts).
prove(M, bagof(T, G, L), Facts) :-
    bagof(T-F, prove(M, G, F), Pairs),
    pairs_keys_values(Pairs, L, Lists),
    append(Lists, Facts).
prove(M, aggregate_all(Spec, G, R), Facts) :-
    findall(Spec-F, prove(M, G, F), Pairs),
    pairs_keys_values(Pairs, Specs, Lists),
    aggregate_all(Spec, member(Spec, Specs), R),
    append(Lists, Facts).
prove(_, M:G, Facts) :-
    prove(M, G, Facts).
prove(M, G, Facts) :-
    \+ construct(G),
    (   system_goal(M:G)
    ->  call(M:G),
        Facts = []
    ;   definition_module(M:G, DefM),
        clause(DefM:G, Body),
        (   Body == true
        ->  fact_leaves(DefM, G, Facts)
        ;   prove(DefM, Body, Facts)
        )
    ).

% construct(@Goal): a goal that prove/3 handles by
% a clause of its own.
construct(true).
construct((_, _)).
construct((_ ; _)).
construct(\+ _).
construct(once(_)).
construct(findall(_, _, _)).
construct(bagof(_, _, _)).
construct(aggregate_all(_, _, _)).
construct(_:_).

% system_goal(+Goal): a built-in or a predicate of
% a library module, executed and not interpreted.
system_goal(G) :-
    predicate_property(G, built_in).
system_goal(G) :-
    predicate_property(G, imported_from(Lib)),
    module_property(Lib, class(library)).

% definition_module(+Goal, -Module): Module holds
% the clauses of the predicate of Goal.
definition_module(M:G, DefM) :-
    (   predicate_property(M:G,
                           imported_from(DefM))
    ->  true
    ;   DefM = M
    ).

% fact_leaves(+Module, +Fact, -Facts): Facts is
% [Fact] as a goal that user can call when Fact
% belongs to a relation defined by facts alone,
% and [] for the base case of a recursive
% predicate.
fact_leaves(M, Fact, Facts) :-
    (   \+ predicate_property(M:Fact,
                              number_of_rules(0))
    ->  Facts = []
    ;   predicate_property(user:Fact, visible)
    ->  Facts = [Fact]
    ;   Facts = [M:Fact]
    ).

% 31-11.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 31. Integration: Scripts, Embedding, and Debugger Extensions: 31.9 Prolog as a Verifier for LLM-Based Agents.
% Program block 11 of the chapter.

% print_verdict(+Text): the verdict, one line per
% binding and per fact.
print_verdict(Text) :-
    check_hypothesis(Text, Verdict),
    format("~s: ", [Text]),
    (   Verdict = proved(Answers)
    ->  length(Answers, N),
        format("proved, ~d answer(s)~n", [N]),
        print_answers(Answers)
    ;   Verdict = incomplete(Reason, Answers)
    ->  length(Answers, N),
        format("incomplete (~q), ~d answer(s)~n",
               [Reason, N]),
        print_answers(Answers)
    ;   format("~q~n", [Verdict])
    ).

print_answers(Answers) :-
    forall(member(Names-Facts, Answers),
           print_answer(Names, Facts)).

print_answer(Names, Facts) :-
    forall(member(N = X, Names),
           format("  ~a = ~q~n", [N, X])),
    forall(member(F, Facts),
           format("  ~q~n", [F])).

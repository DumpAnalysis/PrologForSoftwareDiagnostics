% 31-12.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 31. Integration: Scripts, Embedding, and Debugger Extensions: 31.9 Prolog as a Verifier for LLM-Based Agents.
% Program block 12 of the chapter.

% verdict_dict(+Text, +Verdict, -Dict): JSON-ready
% form of a verdict.
verdict_dict(Text, Verdict, Dict) :-
    (   Verdict = proved(Answers)
    ->  answers_dict(Text, "proved", true,
                     Answers, Dict)
    ;   Verdict = incomplete(Reason, Answers)
    ->  answers_dict(Text, "incomplete", false,
                     Answers, Dict0),
        term_text(Reason, S),
        Dict = Dict0.put(reason, S)
    ;   Verdict == not_proved
    ->  answers_dict(Text, "not_proved", true,
                     [], Dict)
    ;   Verdict = rejected(Why),
        term_text(Why, S),
        Dict = _{hypothesis:Text,
                 verdict:"rejected", reason:S}
    ).

answers_dict(Text, Kind, Complete, Answers, D) :-
    maplist(answer_dict, Answers, Dicts),
    length(Answers, N),
    D = _{hypothesis:Text, verdict:Kind,
          complete:Complete, answers_shown:N,
          answers:Dicts}.

answer_dict(Names-Facts, D) :-
    maplist(binding_pair, Names, Pairs),
    dict_pairs(BDict, _, Pairs),
    maplist(term_text, Facts, Strings),
    D = _{bindings:BDict, evidence:Strings}.

% binding_pair(+Binding, -Pair): the agent's
% variable name with its value as text, or null
% when the proof left the variable unbound.
binding_pair(Name = Term, Name-Value) :-
    (   var(Term)
    ->  Value = null
    ;   term_text(Term, Value)
    ).

% term_text(+Term, -String): Term as quoted Prolog
% text that reads back as Term; a variable inside
% it is written as a letter, or as _ if it occurs
% once.
term_text(Term, String) :-
    copy_term(Term, Copy),
    numbervars(Copy, 0, _, [singletons(true)]),
    term_string(Copy, String, [numbervars(true)]).

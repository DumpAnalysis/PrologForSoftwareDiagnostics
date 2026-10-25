% 31-10.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 31. Integration: Scripts, Embedding, and Debugger Extensions: 31.9 Prolog as a Verifier for LLM-Based Agents.
% Program block 10 of the chapter.

% check_hypothesis(+Text, -Verdict): the verdict
% on the hypothesis Text under the default limits.
check_hypothesis(Text, Verdict) :-
    check_hypothesis(Text, [], Verdict).

% check_hypothesis(+Text, +Options, -Verdict):
% Verdict is proved(Answers), not_proved,
% incomplete(Reason, Answers), or rejected(Why);
% an answer is Bindings-Facts. Options: chars(N),
% answers(N), inferences(N).
check_hypothesis(Text, Options, Verdict) :-
    catch(verify(Text, Options, Verdict),
          error(Why, _),
          Verdict = rejected(Why)).

verify(Text, Options, Verdict) :-
    option(chars(MaxChars), Options, 200),
    string_length(Text, Length),
    (   Length > MaxChars
    ->  Verdict = rejected(input_limit(MaxChars))
    ;   term_string(Goal, Text,
                    [variable_names(Names)]),
        must_be(callable, Goal),
        verify(Goal, Names, Options, Verdict)
    ).

% verify(+Goal, +Names, +Options, -Verdict): the
% verdict on the parsed goal; Names are the
% agent's variable names.
verify(Goal, Names, Options, Verdict) :-
    (   admitted(Goal)
    ->  safe_goal(Goal),
        collect(Goal, Names, Options, Verdict)
    ;   unsupported(Goal, Leaf),
        maplist(name_variable, Names),
        Verdict = rejected(unsupported(Leaf))
    ).

% name_variable(+Binding): bind the variable of a
% Name = Var pair so that it prints as Name.
name_variable(Name = Var) :-
    Var = '$VAR'(Name).

% collect(+Goal, +Names, +Options, -Verdict): the
% answers of Goal with their facts, within the
% limits on answers and inferences.
collect(Goal, Names, Options, Verdict) :-
    option(answers(MaxA), Options, 10),
    option(inferences(MaxI), Options, 1_000_000),
    Chunk is MaxA + 1,
    call_with_inference_limit(
        once(findnsols(Chunk, Names-Facts,
                       answer(Goal, Facts),
                       Found)),
        MaxI, Result),
    (   Result == inference_limit_exceeded
    ->  Reason = inference_limit(MaxI),
        Verdict = incomplete(Reason, [])
    ;   length(Found, N),
        N > MaxA
    ->  length(Answers, MaxA),
        append(Answers, _, Found),
        Reason = answer_limit(MaxA),
        Verdict = incomplete(Reason, Answers)
    ;   Found == []
    ->  Verdict = not_proved
    ;   Verdict = proved(Found)
    ).

% answer(+Goal, -Facts): one proof of Goal, called
% in user, with its facts, each once.
answer(Goal, Facts) :-
    prove(user, Goal, Facts0),
    list_to_set(Facts0, Facts).

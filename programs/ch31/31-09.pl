% 31-09.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 31. Integration: Scripts, Embedding, and Debugger Extensions: 31.9 Prolog as a Verifier for LLM-Based Agents.
% Program block 9 of the chapter.

% supported(@Goal, -Subgoals): Goal is a control
% construct of the vocabulary over Subgoals.
supported((A, B), [A, B]).
supported((A ; B), [A, B]).
supported(\+ A, [A]).
supported(once(A), [A]).
supported(findall(_, G, _), [G]).
supported(aggregate_all(_, G, _), [G]).

% comparison(@Goal): an arithmetic comparison.
comparison(_ < _).
comparison(_ > _).
comparison(_ =< _).
comparison(_ >= _).
comparison(_ =:= _).
comparison(_ =\= _).

% admitted(@Goal): Goal is in the vocabulary: a
% supported construct over admitted goals, a
% comparison, or an export of patterns_dump.
admitted(Goal) :-
    callable(Goal),
    Goal \= _:_,
    (   supported(Goal, Subgoals)
    ->  maplist(admitted, Subgoals)
    ;   comparison(Goal)
    ->  true
    ;   predicate_property(Goal,
                imported_from(patterns_dump))
    ).

% unsupported(@Goal, -Leaf): Goal is not admitted
% and Leaf is its leftmost subgoal that is not.
unsupported(Goal, Leaf) :-
    (   callable(Goal),
        supported(Goal, Subgoals),
        member(Sub, Subgoals),
        \+ admitted(Sub)
    ->  unsupported(Sub, Leaf)
    ;   Leaf = Goal
    ).

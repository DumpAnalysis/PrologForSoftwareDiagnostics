% 17-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 17. The Pattern as a Predicate: 17.3 Evidence.
% Program block 3 of the chapter.

% entails(Facts, Condition): Condition follows
% from the list Facts alone: a conjunction of
% goals, each a member of Facts or an arithmetic
% comparison between values the members bound.
entails(Facts, Condition) :-
    (   Condition = (A, B)
    ->  entails(Facts, A),
        entails(Facts, B)
    ;   comparison(Condition)
    ->  call(Condition)
    ;   member(Condition, Facts)
    ).

% comparison(Goal): Goal is an arithmetic
% comparison.
comparison(_ < _).
comparison(_ > _).
comparison(_ =< _).
comparison(_ >= _).
comparison(_ =:= _).
comparison(_ =\= _).

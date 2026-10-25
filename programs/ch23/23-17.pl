% 23-17.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 23. Dump Quality, Composition, and Reports: 23.10.3 The Evidence Contract from an Importing Module.
% Program block 17 of the chapter.

% outcome(Goal, Outcome): true or false for a goal
% that succeeds or fails without binding anything,
% or raises(E) for one that raises E.
outcome(Goal, Outcome) :-
    catch(( \+ \+ Goal
          ->  Outcome = true
          ;   Outcome = false
          ),
          error(E, _),
          Outcome = raises(E)).

% agrees(Type, X): must_be(Type, X) and its
% derivation from an empty list have the same
% outcome, up to variable renaming; otherwise the
% two outcomes are printed.
agrees(Type, X) :-
    outcome(must_be(Type, X), Library),
    outcome(derivable([], must_be(Type, X)),
            Derived),
    (   Library =@= Derived
    ->  true
    ;   format("~q on ~q:~n", [Type, X]),
        report(library, Library),
        report(derived, Derived)
    ).

report(Side, raises(E)) :-
    !,
    format("  ~w raises~n    ~q~n", [Side, E]).
report(Side, Outcome) :-
    format("  ~w ~q~n", [Side, Outcome]).

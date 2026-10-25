% 17-12.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 17. The Pattern as a Predicate: 17.8 Absence and the Closed World.
% Program block 12 of the chapter.

% source(Relation, Command, Log): as in Chapter
% 15, for the relations this section asks about.
source(exception_record/3, '.exr -1',
       'dump1.log').
source(unloaded_module/2, lm, 'dump1.log').

% dump_info(Key, Value), ran(Command, Outcome),
% capture_policy(Relation, Needs): the capture
% record of Chapter 15 for the same relations.
% Dynamic, for the checks at the end of this
% section.
:- dynamic dump_info/2, ran/2, capture_policy/2.

dump_info(file, 'dump1.dmp').
dump_info(stream, unloaded_modules).
ran('.exr -1', ok).
ran(lm, ok).
capture_policy(exception_record/3, []).
capture_policy(unloaded_module/2,
               [stream(unloaded_modules)]).

% missing(Need): the recorded capture does not
% meet Need, a stream need; any other kind of
% need is an error.
missing(stream(S)) :-
    \+ dump_info(stream, S).
missing(Need) :-
    Need \= stream(_),
    domain_error(capture_need, Need).

% coverage(Relation, Status): complete when a
% policy is declared, a capture is recorded, the
% command ran and succeeded, and every need is
% met; incomplete(Missing) when needs are unmet or
% the command failed; unknown when the policy,
% the capture, or the command's run is not
% recorded.
coverage(Relation, Status) :-
    (   capture_policy(Relation, Needs),
        dump_info(_, _),
        source(Relation, Command, _),
        ran(Command, Outcome)
    ->  findall(Need,
                ( member(Need, Needs),
                  missing(Need) ),
                Unmet),
        (   Outcome == ok
        ->  Missing = Unmet
        ;   Missing = [ran(Command, Outcome)
                       | Unmet]
        ),
        (   Missing == []
        ->  Status = complete
        ;   Status = incomplete(Missing)
        )
    ;   Status = unknown
    ).

% absence(Relation, Status): Status is present
% when facts of Relation are loaded; absent when
% there are none, the command that produces them
% was run, and the coverage of Relation is
% complete; and unknown otherwise.
absence(F/A, Status) :-
    functor(Goal, F, A),
    (   current_predicate(F/A),
        call(Goal)
    ->  Status = present
    ;   source(F/A, _, _),
        coverage(F/A, complete)
    ->  Status = absent
    ;   Status = unknown
    ).

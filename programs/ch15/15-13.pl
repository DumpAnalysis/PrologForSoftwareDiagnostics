% 15-13.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 15. Memory Dumps as Knowledge Bases: 15.5 Unknowns and Provenance.
% Program block 13 of the chapter.

% missing(Need, Scope, What): the recorded capture
% does not meet Need within Scope, which is all or
% thread(TID), and What names what is missing. A
% need outside the vocabulary raises an error.
missing(stream(S), _, stream(S)) :-
    \+ dump_info(stream, S).
missing(memory(M), _, memory(M)) :-
    \+ dump_info(memory, M).
missing(stacks(K), _, stacks(K)) :-
    \+ dump_info(stacks, K).
missing(relation(R), Scope,
        relation(R, Status)) :-
    coverage(R, Scope, Status),
    Status \== complete.
missing(every_thread(C), all, covering(C, T)) :-
    thread(T, _),
    \+ covering(C, T).
missing(every_thread(C), thread(T),
        covering(C, T)) :-
    \+ covering(C, T).
missing(Need, _, _) :-
    \+ need(Need),
    domain_error(capture_need, Need).

% coverage(Relation, Status): Status is complete
% when the absence of a fact of Relation may be
% read as evidence, incomplete(Missing) when the
% recorded capture or command run falls short in
% the ways Missing lists, and unknown when the
% policy, the capture, or the command's run is
% not recorded.
coverage(Relation, Status) :-
    coverage(Relation, all, Status).

% thread_coverage(Relation, TID, Status): as
% coverage/2, for the facts of Relation about
% thread TID alone.
thread_coverage(Relation, TID, Status) :-
    coverage(Relation, thread(TID), Status).

coverage(Relation, Scope, Status) :-
    (   capture_policy(Relation, Needs),
        dump_info(_, _),
        source(Relation, Command, _),
        (   Command == derived
        ->  Outcome = ok
        ;   ran(Command, Outcome)
        )
    ->  findall(What,
                ( member(Need, Needs),
                  missing(Need, Scope, What) ),
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

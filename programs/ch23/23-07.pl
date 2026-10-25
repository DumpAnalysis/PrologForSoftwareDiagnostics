% 23-07.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 23. Dump Quality, Composition, and Reports: 23.6 Corrupt Dump.
% Program block 7 of the chapter.

% census(Counts): the number of facts of each
% predicate of the schema.
census(Counts) :-
    findall(Name/Arity-N,
            ( schema_predicate(Name/Arity),
              functor(Goal, Name, Arity),
              aggregate_all(count, Goal, N)
            ),
            Counts).

schema_predicate(process/2).
schema_predicate(module/3).
schema_predicate(module_info/3).
schema_predicate(thread/2).
schema_predicate(thread_time/3).
schema_predicate(thread_state/2).
schema_predicate(frame/5).
schema_predicate(exception_record/3).
schema_predicate(exception_info/3).
schema_predicate(critical_section/4).
schema_predicate(waits_for/3).
schema_predicate(handle_count/3).
schema_predicate(heap/4).
schema_predicate(last_error/2).
schema_predicate(hooked/3).

% print_census: one line per schema predicate.
print_census :-
    census(Counts),
    forall(member(Pred-N, Counts),
           format("~w~t~20|~t~d~4+~n",
                  [Pred, N])).

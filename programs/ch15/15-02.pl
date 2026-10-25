% 15-02.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 15. Memory Dumps as Knowledge Bases: 15.2 The Schema.
% Program block 2 of the chapter.

% schema(Relation, Fields): Relation is a relation
% of the dump schema; Fields names its arguments
% in order.
schema(process/2, [pid, name]).
schema(module/3, [name, base, size]).
schema(module_info/3, [name, key, value]).
schema(thread/2, [tid, pid]).
schema(thread_time/3, [tid, user_ms, kernel_ms]).
schema(thread_state/2, [tid, state]).
schema(frame/5,
       [tid, number, module, function, offset]).
schema(exception_record/3, [tid, code, address]).
schema(exception_info/3, [tid, key, value]).
schema(critical_section/4,
       [address, owner, waiters, recursion]).
schema(waits_for/3, [tid, kind, address]).
schema(handle_count/3, [pid, type, count]).
schema(heap/4,
       [address, reserved, committed, free]).
schema(last_error/2, [tid, code]).
schema(hooked/3, [function, module, hooker]).

% field(Fact, Name, Value): Value is the argument
% of Fact that the schema names Name.
field(Fact, Name, Value) :-
    functor(Fact, F, A),
    schema(F/A, Fields),
    nth1(Index, Fields, Name),
    arg(Index, Fact, Value).

% fact_count(Relation, Count): Count facts of the
% schema relation Relation are loaded.
fact_count(F/A, Count) :-
    schema(F/A, _),
    functor(Goal, F, A),
    aggregate_all(count, Goal, Count).

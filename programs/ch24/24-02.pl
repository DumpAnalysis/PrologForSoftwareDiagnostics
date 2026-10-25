% 24-02.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 24. Trace Structure: 24.1 Basic Facts.
% Program block 2 of the chapter.

% basic_facts(Facts): Facts is a list of Key=Value
% terms describing the trace as a whole.
basic_facts(Facts) :-
    aggregate_all(count, msg(_, _, _, _, _, _),
                  Count),
    aggregate_all(min(T), msg(_, T, _, _, _, _),
                  First),
    aggregate_all(max(T), msg(_, T, _, _, _, _),
                  Last),
    aggregate_all(set(P), msg(_, _, P, _, _, _),
                  PIDs),
    aggregate_all(set(T), msg(_, _, _, T, _, _),
                  TIDs),
    aggregate_all(set(C), msg(_, _, _, _, C, _),
                  Cs),
    Duration is Last - First,
    Facts = [messages=Count, first=First,
             last=Last, duration=Duration,
             processes=PIDs, threads=TIDs,
             components=Cs].

% print_basic_facts: one line per basic fact;
% lists are printed as their lengths.
print_basic_facts :-
    basic_facts(Facts),
    forall(member(Key=Value, Facts),
           print_basic_fact(Key, Value)).

print_basic_fact(Key, Value) :-
    (   is_list(Value)
    ->  length(Value, Len),
        format("~a~t~12|~d~n", [Key, Len])
    ;   float(Value)
    ->  format("~a~t~12|~3f~n", [Key, Value])
    ;   format("~a~t~12|~w~n", [Key, Value])
    ).

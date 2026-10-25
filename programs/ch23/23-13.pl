% 23-13.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 23. Dump Quality, Composition, and Reports: 23.10 The Analysis Report.
% Program block 13 of the chapter.

% not_examined(What): data the report would need
% and the knowledge base does not hold.
not_examined('heap verification results').
not_examined('heap operation logs').
not_examined('raw stack words').
not_examined('function parameters').
not_examined('the environment block').
not_examined('executable regions not in modules').

% limit_lines(Lines): what the report does not
% claim.
limit_lines([
    "- that any recognized pattern is the cause",
    "  of the failure; a pattern is a state the",
    "  dump shows, and causes are inferred;",
    "- that a pattern not recognized is absent;",
    "  the recognizers see the facts the schema",
    "  holds, and the dump holds more;",
    "- that the thresholds are right for this",
    "  process; they encode an analyst's limits;",
    "- that the stack traces are correct; they",
    "  are the debugger's reconstructions;",
    "- anything about time before or after the",
    "  moment the dump was written, except what",
    "  the step dumps show at their moments."
]).

report_header :-
    process(PID, Name),
    format("Analysis report: ~a (PID ~d)~n",
           [Name, PID]),
    aggregate_all(count, thread(_, _), Threads),
    aggregate_all(count, module(_, _, _),
                  Modules),
    dump_info(kind, Kind),
    format("~a memory dump, ", [Kind]),
    format("~d threads, ~d modules~n",
           [Threads, Modules]),
    nl.

report_recognized :-
    format("Recognized, most severe first:~n"),
    findall(Rank-Pattern,
            recognized(Rank, Pattern),
            Pairs),
    keysort(Pairs, Sorted),
    forall(member(Rank-Pattern, Sorted),
           report_pattern(Rank, Pattern)),
    nl.

report_suspected :-
    format("Suspected, for the analyst:~n"),
    forall(suspicion(Pattern, Instance),
           ( format("[suspected] ~a~n",
                    [Pattern]),
             print_instance(Instance)
           )),
    nl.

report_absent :-
    format("Looked for and not recognized:~n"),
    forall(( severity(Pattern, _),
             \+ instance(Pattern, _)
           ),
           format("    ~a~n", [Pattern])),
    nl.

report_not_examined :-
    format("Not examined, for want of facts:~n"),
    forall(not_examined(What),
           format("    ~a~n", [What])),
    nl.

report_limits :-
    format("This report does not claim~n"),
    limit_lines(Lines),
    forall(member(Line, Lines),
           format("~s~n", [Line])).

% report: the analysis report of the dump.
report :-
    report_header,
    report_recognized,
    report_suspected,
    report_absent,
    report_not_examined,
    report_limits.

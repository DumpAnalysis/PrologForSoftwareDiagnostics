% 24-21.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 24. Trace Structure: 24.19 Trace Summary.
% Program block 21 of the chapter.

% trace_summary: print a summary of the trace.
trace_summary :-
    print_basic_facts,
    forall(dimension(Dim),
           ( trace_partition(Dim, Partition),
             format("by ~a~n", [Dim]),
             print_partition(Partition) )),
    message_directory(Directory),
    length(Directory, Kinds),
    aggregate_all(count, singleton_event(_),
                  Singletons),
    text_set("Error", Errors),
    length(Errors, ErrorCount),
    format("kinds~t~12|~d~n", [Kinds]),
    format("singletons~t~12|~d~n", [Singletons]),
    format("errors~t~12|~d ~w~n",
           [ErrorCount, Errors]).

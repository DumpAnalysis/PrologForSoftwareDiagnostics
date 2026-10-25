% 28-14.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 28. Sequences, Motifs, and Correlation: 28.13 Visitor Trace.
% Program block 14 of the chapter.

% visitor_trace(?TID, -Components): the set of
% components thread TID wrote to, when it
% visited at least three.
visitor_trace(TID, Components) :-
    trace_thread(TID),
    aggregate_all(set(C),
                  msg(_, _, _, TID, C, _),
                  Components),
    length(Components, L),
    L >= 3.

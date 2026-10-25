% 18-01.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 18. Stack Traces and Threads.
% Program block 1 of the chapter.

:- [dump1].
:- use_module(library(pprint)).

% threshold(Name, Value): the thresholds of this
% chapter, as facts an analyst can inspect.
threshold(spiking_share, 25).
threshold(frame_run, 4).
threshold(set_size, 2).

% pattern(Name, Artifact, Chapter): the patterns
% this chapter recognizes with a predicate.
pattern('Stack Trace', memory_dump, 18).
pattern(
    'Stack Trace Collection (Unmanaged Space)',
    memory_dump, 18).
pattern('Stack Trace Collection (Predicate)',
        memory_dump, 18).
pattern('Main Thread', memory_dump, 18).
pattern('Special Thread', memory_dump, 18).
pattern('Passive Thread', memory_dump, 18).
pattern('Spiking Thread', memory_dump, 18).
pattern('Blocked Thread (Software)',
    memory_dump, 18).
pattern('Active Thread', memory_dump, 18).
pattern('Stack Trace Signature', memory_dump, 18).
pattern('Least Common Frame', memory_dump, 18).
pattern('Stack Trace Set', memory_dump, 18).
pattern('Frame Regularity', memory_dump, 18).
pattern('Caller-n-Callee', memory_dump, 18).
pattern('Procedure Call Chain', memory_dump, 18).
pattern('Incorrect Stack Trace', memory_dump, 18).
pattern('Truncated Stack Trace', memory_dump, 18).
pattern('Coincidental Symbolic Information',
        memory_dump, 18).
pattern('Glued Stack Trace', memory_dump, 18).
pattern('Execution Residue (User Space)',
        memory_dump, 18).

% show(Term): print Term over several lines that
% fit the width of this book's pages.
show(Term) :-
    print_term(Term, [right_margin(46),
                      tab_width(0)]),
    nl.

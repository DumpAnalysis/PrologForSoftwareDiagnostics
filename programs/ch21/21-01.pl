% 21-01.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 21. Memory, Heaps, Handles, and Leaks.
% Program block 1 of the chapter.

:- [dump1].

% pattern(Name, Artifact, Chapter): the catalog
% entries treated in this chapter.
pattern('Insufficient Memory (Committed Memory)',
    memory_dump, 21).
pattern('Handle Leak', memory_dump, 21).
pattern('Insufficient Memory (Handle Leak)',
    memory_dump, 21).
pattern('Memory Leak (Process Heap)',
    memory_dump, 21).
pattern('Memory Fluctuation', memory_dump, 21).
pattern(
    'Dynamic Memory Corruption (Process Heap)',
    memory_dump, 21).
pattern('Double Free (Process Heap)',
    memory_dump, 21).
pattern('Invalid Handle (General)',
    memory_dump, 21).
pattern('Paged Out Data', memory_dump, 21).
pattern('Shared Buffer Overwrite',
    memory_dump, 21).
pattern('Value References', memory_dump, 21).
pattern('Regular Data', memory_dump, 21).
pattern('Data Correlation (Function Parameters)',
    memory_dump, 21).

% threshold(Name, Value): the analyst's limits.
threshold(committed_ratio, 0.85).
threshold(large_heap_kb, 1048576).
threshold(committed_total_kb, 1572864).
threshold(handle_type_count, 5000).
threshold(handle_total_count, 10000).
threshold(leak_growth_kb, 65536).

% print_evidence(Evidence): the pattern name, the
% instance, and one line per supporting fact.
print_evidence(evidence(Name, Instance, Facts)) :-
    format("~a~n  instance: ~q~n",
           [Name, Instance]),
    forall(member(Fact, Facts),
           print_fact(Fact)).

% print_fact(Fact): Fact on one indented line, as
% the toplevel would print it.
print_fact(Fact) :-
    Options = [ quoted(true),
                spacing(next_argument)
              ],
    format("  ~W~n", [Fact, Options]).

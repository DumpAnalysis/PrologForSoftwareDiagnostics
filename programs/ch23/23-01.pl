% 23-01.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 23. Dump Quality, Composition, and Reports.
% Program block 1 of the chapter.

:- [dump1].
:- use_module(patterns_dump).

% pattern(Name, Artifact, Chapter): the catalog
% entries treated in this chapter.
pattern('Manual Dump (Process)', memory_dump, 23).
pattern('Truncated Dump', memory_dump, 23).
pattern('Inconsistent Dump', memory_dump, 23).
pattern('Early Crash Dump', memory_dump, 23).
pattern('False Positive Dump', memory_dump, 23).
pattern('Corrupt Dump', memory_dump, 23).
pattern('No Current Thread', memory_dump, 23).
pattern('Step Dumps', memory_dump, 23).

% dump_info(Key, Value): what the debugger reports
% about the dump file itself. An extension of the
% schema.
dump_info(kind, process).
dump_info(truncated, false).
dump_info(current_thread, 109).
dump_info(process_uptime_s, 1860).

% threshold(Name, Value): the module's thresholds
% are those of Chapters 18 to 21; this chapter
% adds its one limit to the multifile predicate.
patterns_dump:threshold(early_uptime_s, 10).

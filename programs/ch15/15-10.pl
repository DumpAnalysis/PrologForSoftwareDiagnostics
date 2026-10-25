% 15-10.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 15. Memory Dumps as Knowledge Bases: 15.5 Unknowns and Provenance.
% Program block 10 of the chapter.

% source(Relation, Command, Log): the facts of
% Relation were parsed from the output of Command
% in the log file Log.
source(process/2, '!analyze -v', 'dump1.log').
source(module/3, lm, 'dump1.log').
source(module_info/3, lmv, 'dump1.log').
source(thread/2, '~*kn', 'dump1.log').
source(thread_time/3, '!runaway 7', 'dump1.log').
source(thread_state/2, derived, 'dump1.log').
source(frame/5, '~*kn', 'dump1.log').
source(exception_record/3, '.exr -1',
       'dump1.log').
source(exception_info/3, '.exr -1', 'dump1.log').
source(critical_section/4, '!locks', 'dump1.log').
source(waits_for/3, '!cs', 'dump1.log').
source(handle_count/3, '!handle 0 0',
       'dump1.log').
source(heap/4, '!heap -s', 'dump1.log').
source(last_error/2, '!teb', 'dump1.log').
source(last_status/2, '!teb', 'dump1.log').
source(hooked/3, analyst, 'dump1.notes').

% 23-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 23. Dump Quality, Composition, and Reports: 23.4 Early Crash Dump.
% Program block 5 of the chapter.

% early_sign(Sign): a symptom that the process had
% barely started when the dump was written.
early_sign(short_uptime(Seconds)) :-
    dump_info(process_uptime_s, Seconds),
    threshold(early_uptime_s, Max),
    Seconds < Max.
early_sign(single_thread) :-
    aggregate_all(count, thread(_, _), 1).
early_sign(thread_in_loader(TID)) :-
    bottom_frame(TID, 'LdrInitializeThunk').

% early_crash_dump(Signs): the dump shows at least
% one sign of an early crash.
early_crash_dump(Signs) :-
    findall(Sign, early_sign(Sign), Signs),
    Signs \== [].

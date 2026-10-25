% 07-17.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 7. Control: 7.7 Diagnostic Use.
% Program block 17 of the chapter.

% unreferenced_module(M): M is loaded and appears
% in no frame of any stack trace.
unreferenced_module(M) :-
    module(M, _, _),
    \+ frame(_, _, M, _, _).

% idle_thread(TID): TID has no exception, waits
% for nothing recorded, and was not running.
idle_thread(TID) :-
    thread(TID, _),
    \+ exception_record(TID, _, _),
    \+ waits_for(TID, _, _),
    \+ thread_state(TID, running).

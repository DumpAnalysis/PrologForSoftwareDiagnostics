% 23-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 23. Dump Quality, Composition, and Reports: 23.2 Truncated Dump.
% Program block 3 of the chapter.

% bottom_frame(TID, Function): the function of the
% deepest frame of TID.
bottom_frame(TID, Function) :-
    thread(TID, _),
    aggregate_all(max(N, F),
                  frame(TID, N, _, F, _),
                  max(_, Function)).

% truncation_sign(Sign): one symptom of a dump
% that holds less than the process had.
truncation_sign(flagged) :-
    dump_info(truncated, true).
truncation_sign(module_missing(Module)) :-
    distinct(Module, frame(_, _, Module, _, _)),
    \+ module(Module, _, _).
truncation_sign(no_frames(TID)) :-
    thread(TID, _),
    \+ frame(TID, _, _, _, _).
truncation_sign(incomplete_stack(TID)) :-
    bottom_frame(TID, Function),
    Function \== 'RtlUserThreadStart'.

% truncated_dump(Signs): the dump shows at least
% one sign of truncation.
truncated_dump(Signs) :-
    findall(Sign, truncation_sign(Sign), Signs),
    Signs \== [].

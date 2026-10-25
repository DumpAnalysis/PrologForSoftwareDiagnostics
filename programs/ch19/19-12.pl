% 19-12.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 19. Exceptions and Faults: 19.9.1 The Two Run Thresholds.
% Program block 12 of the chapter.

% synthetic_stack(TID, Functions): add thread TID
% to the process with one frame per function of
% Functions, top frame first, all in appserver.
synthetic_stack(TID, Functions) :-
    assertz(thread(TID, 4120)),
    forall(nth0(N, Functions, F),
           assertz(frame(TID, N, appserver, F,
                         0x10))).

% run_report(TID): the depth of TID, the runs that
% reach frame_run, and the forms of its findings.
run_report(TID) :-
    stack_depth(TID, Depth),
    findall(C, frame_regularity(TID, _, C), Runs),
    findall(Form,
            ( stack_overflow(TID, F),
              functor(F, Form, 3)
            ),
            Forms),
    format("~d depth ~d runs ~w ~w~n",
           [TID, Depth, Runs, Forms]).

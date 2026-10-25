% 07-14.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 7. Control: 7.7 Diagnostic Use.
% Program block 14 of the chapter.

% top_run(TID, Function, Count): the top Count
% frames of TID all name Function, and frame Count
% does not.
top_run(TID, Function, Count) :-
    frame(TID, 0, _, Function, _),
    run_from(TID, 1, Function, 1, Count).

% run_from(TID, N, Function, Acc0, Count): Count
% is Acc0 plus the frames from N on that continue
% the run of Function.
run_from(TID, N, Function, Acc0, Count) :-
    (   frame(TID, N, _, Function, _)
    ->  Acc is Acc0 + 1,
        succ(N, N1),
        run_from(TID, N1, Function, Acc, Count)
    ;   Count = Acc0
    ).

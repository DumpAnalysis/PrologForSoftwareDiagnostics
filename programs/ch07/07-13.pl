% 07-13.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 7. Control: 7.7 Diagnostic Use.
% Program block 13 of the chapter.

% stack_trace(TID, Frames): Frames is the list of
% frame/5 terms of thread TID, top frame first.
stack_trace(TID, Frames) :-
    frames_from(TID, 0, Frames).

% frames_from(TID, N, Frames): Frames is the list
% of frames of TID numbered N and above.
frames_from(TID, N, Frames) :-
    (   frame(TID, N, M, F, O)
    ->  Frames = [frame(TID, N, M, F, O) | Rest],
        succ(N, N1),
        frames_from(TID, N1, Rest)
    ;   Frames = []
    ).

% 05-14.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 5. Lists and Recursion: 5.6 Diagnostic Use.
% Program block 14 of the chapter.

% frames_dl(TID, N, Frames, Hole): Frames is the
% frames of TID from N on, followed by Hole.
frames_dl(TID, N,
          [frame(TID, N, M, F, O) | Frames],
          Hole) :-
    frame(TID, N, M, F, O),
    succ(N, N1),
    frames_dl(TID, N1, Frames, Hole).
frames_dl(TID, N, Hole, Hole) :-
    \+ frame(TID, N, _, _, _).

% two_stack_traces(TID1, TID2, Frames): the frames
% of TID1 followed by those of TID2.
two_stack_traces(TID1, TID2, Frames) :-
    frames_dl(TID1, 0, Frames, Hole),
    frames_dl(TID2, 0, Hole, []).

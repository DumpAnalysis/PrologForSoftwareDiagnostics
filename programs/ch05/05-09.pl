% 05-09.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 5. Lists and Recursion: 5.6 Diagnostic Use.
% Program block 9 of the chapter.

% stack_trace(TID, Frames): Frames is the list of
% frame/5 terms of thread TID, top frame first.
stack_trace(TID, Frames) :-
    frames_from(TID, 0, Frames).

% frames_from(TID, N, Frames): Frames is the list
% of frames of TID numbered N and above.
frames_from(TID, N,
            [frame(TID, N, M, F, O) | Frames]) :-
    frame(TID, N, M, F, O),
    succ(N, N1),
    frames_from(TID, N1, Frames).
frames_from(TID, N, []) :-
    \+ frame(TID, N, _, _, _).

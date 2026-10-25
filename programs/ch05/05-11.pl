% 05-11.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 5. Lists and Recursion: 5.6 Diagnostic Use.
% Program block 11 of the chapter.

% frame_modules(Frames, Modules): Modules is the
% list of module names of Frames, in frame order.
frame_modules([], []).
frame_modules([frame(_, _, M, _, _) | Frames],
              [M | Modules]) :-
    frame_modules(Frames, Modules).

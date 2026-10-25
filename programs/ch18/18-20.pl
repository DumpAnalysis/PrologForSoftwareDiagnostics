% 18-20.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 18. Stack Traces and Threads: 18.20 Glued Stack Trace.
% Program block 20 of the chapter.

% glued_frames(Frames): some frame of the list
% Frames names a bottom function and is not the
% last frame.
glued_frames(Frames) :-
    append(_, [Frame, _ | _], Frames),
    Frame = frame(_, _, _, F, _),
    bottom_function(F).

% glued_stack_trace(TID): the stack trace of TID
% has a bottom function above another frame.
glued_stack_trace(TID) :-
    thread(TID, _),
    stack_trace(TID, Frames),
    glued_frames(Frames).

% 18-18.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 18. Stack Traces and Threads: 18.18 Truncated Stack Trace.
% Program block 18 of the chapter.

% bottom_function(F): F ends a complete user-mode
% stack trace.
bottom_function('RtlUserThreadStart').
bottom_function('LdrInitializeThunk').

% truncated_frames(Frames): the non-empty frame
% list Frames does not end in a bottom function.
truncated_frames(Frames) :-
    last(Frames, frame(_, _, _, F, _)),
    \+ bottom_function(F).

% truncated_stack_trace(TID): the stack trace of
% TID is truncated.
truncated_stack_trace(TID) :-
    thread(TID, _),
    stack_trace(TID, Frames),
    truncated_frames(Frames).

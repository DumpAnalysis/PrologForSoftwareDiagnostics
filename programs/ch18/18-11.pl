% 18-11.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 18. Stack Traces and Threads: 18.11 Stack Trace Signature.
% Program block 11 of the chapter.

% frame_key(Frame, Key): Key is the pair
% Module-Function of the frame/5 term Frame.
frame_key(frame(_, _, M, F, _), M-F).

% stack_trace_signature(TID, Signature): the keys
% of the frames of TID, top frame first.
stack_trace_signature(TID, Signature) :-
    stack_trace(TID, Frames),
    maplist(frame_key, Frames, Signature).

% top_signature(TID, Depth, Signature): the keys
% of the top Depth frames of TID.
top_signature(TID, Depth, Signature) :-
    stack_trace_signature(TID, Full),
    length(Signature, Depth),
    append(Signature, _, Full).

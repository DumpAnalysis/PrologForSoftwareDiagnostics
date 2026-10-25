% 24-11.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 24. Trace Structure: 24.9 Trace Frames.
% Program block 11 of the chapter.

% trace_frames(+Size, -Frames): Frames is the list
% of I-Set pairs dividing the trace into
% consecutive sets of Size messages; the last may
% be shorter. Size is a number of messages, a
% positive integer; any other value is an error.
trace_frames(Size, Frames) :-
    must_be(positive_integer, Size),
    message_space(Space),
    frames(Space, Size, 1, Frames).

frames([], _, _, []).
frames([N | Ns], Size, I, [I-Frame | Frames]) :-
    (   length(Prefix, Size),
        append(Prefix, Suffix, [N | Ns])
    ->  Frame = Prefix,
        Rest = Suffix
    ;   Frame = [N | Ns],
        Rest = []
    ),
    I1 is I + 1,
    frames(Rest, Size, I1, Frames).

% trace_frame(Size, I, Frame): Frame is frame I.
trace_frame(Size, I, Frame) :-
    trace_frames(Size, Frames),
    memberchk(I-Frame, Frames).

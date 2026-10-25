% 24-08.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 24. Trace Structure: 24.6 Message Space.
% Program block 8 of the chapter.

% message_space(Space): Space is the set of all
% messages of the trace.
message_space(Space) :-
    message_set(msg(_, _, _, _, _, _), Space).

% coordinates(N, Point): Point locates message N
% along the ordered and grouped dimensions.
coordinates(N, point(N, Time, PID, TID, C)) :-
    msg(N, Time, PID, TID, C, _).

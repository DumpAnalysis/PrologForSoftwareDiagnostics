% 15-07.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 15. Memory Dumps as Knowledge Bases: 15.3 From Debugger Output to Facts.
% Program block 7 of the chapter.

% write_frame(Frame): write a frame/5 term as a
% fact with a hexadecimal offset.
write_frame(frame(T, N, M, F, O)) :-
    format("frame(~d, ~d, ~q, ~q, 0x~16r).~n",
           [T, N, M, F, O]).

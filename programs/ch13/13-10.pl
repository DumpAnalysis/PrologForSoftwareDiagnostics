% 13-10.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 13. Programs, Modules, Files, and Tooling: 13.5 Debugging, Assertions, and Unit Tests.
% Program block 10 of the chapter.

:- use_module(library(debug)).

% deep_thread(TID, Depth): the stack trace of TID
% has Depth frames, more than nine.
deep_thread(TID, Depth) :-
    stack_trace(TID, Frames),
    length(Frames, Depth),
    debug(depth, "thread ~w: ~w frames",
          [TID, Depth]),
    Depth > 9.

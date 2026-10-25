% 19-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 19. Exceptions and Faults: 19.1 Exception Stack Trace.
% Program block 3 of the chapter.

% exception_stack_trace(TID, Frames): TID has an
% exception record and Frames is its stack trace.
exception_stack_trace(TID, Frames) :-
    exception_record(TID, _, _),
    stack_trace(TID, Frames).

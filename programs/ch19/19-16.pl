% 19-16.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 19. Exceptions and Faults: 19.13 Hidden Exception (User Space).
% Program block 16 of the chapter.

% exception_frame(F): F is a function that raises
% or dispatches an exception.
exception_frame('KiUserExceptionDispatch').
exception_frame('RaiseException').

% hidden_exception(TID, N): TID has no exception
% record and frame N of its trace is an exception
% frame.
hidden_exception(TID, N) :-
    thread(TID, _),
    \+ exception_record(TID, _, _),
    frame(TID, N, _, F, _),
    exception_frame(F).

% 19-14.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 19. Exceptions and Faults: 19.11 Nested Exceptions (User Space).
% Program block 14 of the chapter.

% dispatch_frame(TID, N): frame N of TID is the
% user-mode exception dispatcher.
dispatch_frame(TID, N) :-
    frame(TID, N, ntdll, F, _),
    F == 'KiUserExceptionDispatch'.

% nested_exceptions(TID): the exception of TID was
% raised while an earlier exception of TID was
% being dispatched.
nested_exceptions(TID) :-
    exception_record(TID, _, Addr),
    dispatch_frame(TID, N),
    N > 0,
    frame(TID, 0, M, _, _),
    address_module(Addr, M).

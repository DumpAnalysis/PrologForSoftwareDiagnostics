% 19-19.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 19. Exceptions and Faults: 19.16 Managed Code Exception.
% Program block 19 of the chapter.

% managed_code_exception(TID): TID raised a .NET
% runtime exception.
managed_code_exception(TID) :-
    exception_record(TID, 0xe0434352, _).

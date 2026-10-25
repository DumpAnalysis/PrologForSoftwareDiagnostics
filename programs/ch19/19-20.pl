% 19-20.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 19. Exceptions and Faults: 19.17 Stored Exception.
% Program block 20 of the chapter.

% past_exception(TID, Code, Addr): a stored record
% of TID describes an exception that is not its
% current one.
past_exception(TID, Code, Addr) :-
    stored_exception(TID, _, Code, Addr),
    \+ exception_record(TID, Code, Addr).

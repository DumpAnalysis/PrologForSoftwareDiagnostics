% 19-15.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 19. Exceptions and Faults: 19.12 Multiple Exceptions (User Space).
% Program block 15 of the chapter.

% multiple_exceptions(TIDs): more than one thread
% has an exception record; TIDs lists them.
multiple_exceptions(TIDs) :-
    findall(TID, exception_record(TID, _, _),
            TIDs),
    length(TIDs, Count),
    Count > 1.

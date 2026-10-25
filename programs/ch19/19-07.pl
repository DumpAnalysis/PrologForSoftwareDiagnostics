% 19-07.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 19. Exceptions and Faults: 19.5 Invalid Pointer (General).
% Program block 7 of the chapter.

% invalid_pointer(TID): TID read or wrote through
% a pointer outside the null page.
invalid_pointer(TID) :-
    access_violation(TID),
    exception_info(TID, access, Access),
    Access \== execute,
    exception_info(TID, target, Target),
    threshold(null_page, Limit),
    Target >= Limit.

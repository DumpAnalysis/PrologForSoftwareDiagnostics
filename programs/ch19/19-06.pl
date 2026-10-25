% 19-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 19. Exceptions and Faults: 19.4 NULL Pointer (Code).
% Program block 6 of the chapter.

% null_pointer_code(TID): TID tried to execute
% code at an address in the null page.
null_pointer_code(TID) :-
    access_violation(TID),
    exception_info(TID, access, execute),
    exception_info(TID, target, Target),
    threshold(null_page, Limit),
    Target < Limit.

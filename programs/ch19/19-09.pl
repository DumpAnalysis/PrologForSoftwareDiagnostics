% 19-09.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 19. Exceptions and Faults: 19.7 Wild Code.
% Program block 9 of the chapter.

% wild_code(TID): the exception of TID was raised
% at an address outside the null page and outside
% every module.
wild_code(TID) :-
    exception_record(TID, _, Addr),
    threshold(null_page, Limit),
    Addr >= Limit,
    \+ address_module(Addr, _).

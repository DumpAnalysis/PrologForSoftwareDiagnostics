% 19-13.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 19. Exceptions and Faults: 19.10 Divide by Zero (User Mode).
% Program block 13 of the chapter.

% divide_by_zero(TID): TID divided an integer by
% zero.
divide_by_zero(TID) :-
    exception_record(TID, 0xc0000094, _).

% 19-18.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 19. Exceptions and Faults: 19.15 C++ Exception.
% Program block 18 of the chapter.

% cpp_exception(TID): TID raised a C++ exception.
cpp_exception(TID) :-
    exception_record(TID, 0xe06d7363, _).

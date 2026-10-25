% 21-10.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 21. Memory, Heaps, Handles, and Leaks: 21.8 Invalid Handle (General).
% Program block 10 of the chapter.

% invalid_handle(TID): thread TID raised the
% invalid-handle status or recorded the
% invalid-handle error.
invalid_handle(TID) :-
    thread(TID, _),
    (   exception_record(TID, 0xc0000008, _)
    ;   last_error(TID, 0x6)
    ).

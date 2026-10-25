% 22-17.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 22. Modules, Versions, and Environment: 22.17 Last Error Collection.
% Program block 17 of the chapter.

% win32_error(Code, Name): the names of some Win32
% error codes.
win32_error(0x0, 'ERROR_SUCCESS').
win32_error(0x2, 'ERROR_FILE_NOT_FOUND').
win32_error(0x5, 'ERROR_ACCESS_DENIED').
win32_error(0x6, 'ERROR_INVALID_HANDLE').
win32_error(0x8, 'ERROR_NOT_ENOUGH_MEMORY').
win32_error(0x57, 'ERROR_INVALID_PARAMETER').
win32_error(0x7e, 'ERROR_MOD_NOT_FOUND').
win32_error(0x3e6, 'ERROR_NOACCESS').

% error_name(Code, Name): the name of Code, or
% unknown.
error_name(Code, Name) :-
    (   win32_error(Code, Name)
    ->  true
    ;   Name = unknown
    ).

% last_error_collection(Collection): the TID-Code
% pairs of every thread with a recorded last
% error, by thread.
last_error_collection(Collection) :-
    findall(TID-Code, last_error(TID, Code),
            Pairs),
    keysort(Pairs, Collection).

% print_last_errors: one line per recorded thread.
print_last_errors :-
    last_error_collection(Collection),
    forall(member(TID-Code, Collection),
           ( error_name(Code, Name),
             format("~d~t~6|~16r~t~12|~a~n",
                    [TID, Code, Name])
           )).

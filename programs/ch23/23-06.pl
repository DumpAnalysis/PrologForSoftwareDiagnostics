% 23-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 23. Dump Quality, Composition, and Reports: 23.5 False Positive Dump.
% Program block 6 of the chapter.

% benign_code(Code, Kind): exception codes that a
% process raises and survives when a debugger is
% attached.
benign_code(0x80000003, breakpoint).
benign_code(0x80000004, single_step).
benign_code(0x406d1388, thread_naming).
benign_code(0x40010006, debug_print).

% false_positive_dump(TID, Kind): the exception
% record of TID is of a benign kind and no other
% thread has a record that is not.
false_positive_dump(TID, Kind) :-
    exception_record(TID, Code, _),
    benign_code(Code, Kind),
    \+ ( exception_record(Other, OtherCode, _),
         Other \== TID,
         \+ benign_code(OtherCode, _)
       ).

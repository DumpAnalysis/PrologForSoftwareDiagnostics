% 19-23.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 19. Exceptions and Faults: 19.20 Crash Signature.
% Program block 23 of the chapter.

% crash_signature(TID, Signature): Signature is
% the canonical term sig(Kind, Module, Function,
% Offset) of the fault of TID.
crash_signature(TID, sig(Kind, M, F, O)) :-
    exception_record(TID, Code, _),
    (   status_name(Code, Kind)
    ->  true
    ;   Kind = Code
    ),
    (   problem_frame(TID, frame(_, _, M, F, O))
    ->  true
    ;   M = none,
        F = 'Unknown',
        O = 0
    ).

% print_signature(TID): the signature of TID in
% the debugger's notation.
print_signature(TID) :-
    crash_signature(TID, sig(Kind, M, F, O)),
    format("~d ~a ~a!~a+0x~16r~n",
           [TID, Kind, M, F, O]).

% 08-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 8. Atoms, Strings, and Term Inspection: 8.5 Diagnostic Use.
% Program block 3 of the chapter.

% frame_symbol(Frame, Symbol): Symbol is the
% debugger's text for the frame/5 term Frame.
frame_symbol(frame(_, _, M, F, O), Symbol) :-
    (   F == 'Unknown'
    ->  format(atom(Symbol), "~a+0x~16r", [M, O])
    ;   format(atom(Symbol), "~a!~a+0x~16r",
               [M, F, O])
    ).

% print_frame(TID, N): print frame N of TID as the
% debugger would, with its number.
print_frame(TID, N) :-
    frame(TID, N, M, F, O),
    frame_symbol(frame(TID, N, M, F, O), Symbol),
    format("~`0t~d~2| ~a~n", [N, Symbol]).

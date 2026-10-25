% 05-10.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 5. Lists and Recursion: 5.6 Diagnostic Use.
% Program block 10 of the chapter.

% frame_symbols(Frames, Symbols): Symbols is the
% list of Module-Function pairs of Frames.
frame_symbols([], []).
frame_symbols([frame(_, _, M, F, _) | Frames],
              [M-F | Symbols]) :-
    frame_symbols(Frames, Symbols).

% print_symbols(Symbols): print one
% Module!Function pair per line.
print_symbols([]).
print_symbols([M-F | Symbols]) :-
    write(M), write('!'), write(F), nl,
    print_symbols(Symbols).

% print_stack_trace(TID): print the stack trace of
% TID in the debugger's module!function form.
print_stack_trace(TID) :-
    stack_trace(TID, Frames),
    frame_symbols(Frames, Symbols),
    print_symbols(Symbols).

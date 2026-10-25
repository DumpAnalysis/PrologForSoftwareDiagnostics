% 05-12.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 5. Lists and Recursion: 5.6 Diagnostic Use.
% Program block 12 of the chapter.

% common_suffix(Xs, Ys, Suffix): Suffix is a
% suffix of both Xs and Ys; the longest is first.
common_suffix(Xs, Ys, Suffix) :-
    append(_, Suffix, Xs),
    append(_, Suffix, Ys).

% common_tail(TID1, TID2, Symbols): Symbols is a
% common suffix of the two threads' stack traces.
common_tail(TID1, TID2, Symbols) :-
    stack_trace(TID1, Frames1),
    stack_trace(TID2, Frames2),
    frame_symbols(Frames1, Symbols1),
    frame_symbols(Frames2, Symbols2),
    common_suffix(Symbols1, Symbols2, Symbols).

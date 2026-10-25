% 27-26.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.24 Palimpsest Messages.
% Program block 26 of the chapter.

% palimpsest_messages(+Trace, ?N, -Over, -Under):
% the invariant of message N of Trace is the known
% invariant Over followed by a tail of the known
% invariant Under.
palimpsest_messages(T, N, Over, Under) :-
    trace_text(T, N, _, _, Text),
    invariant(Text, Inv),
    \+ trace_invariant(trace1, Inv),
    trace_invariant(trace1, Over),
    string_concat(Over, Tail, Inv),
    Tail \== "",
    trace_invariant(trace1, Under),
    Under \== Over,
    string_concat(_, Tail, Under).

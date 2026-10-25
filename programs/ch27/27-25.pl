% 27-25.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.23 Marked Message.
% Program block 25 of the chapter.

% marked_message(+Trace, ?N, -Label): message N of
% Trace is a mark with the given Label.
marked_message(T, N, Label) :-
    trace_text(T, N, _, _, Text),
    string_concat("MARK: ", Label, Text).

% between_marks(+Trace, +Step, -Ns): the messages
% between the begin and end marks of Step.
between_marks(T, Step, Ns) :-
    marked_message(T, N1, L1),
    string_concat(Step, " begin", L1),
    marked_message(T, N2, L2),
    string_concat(Step, " end", L2),
    findall(N,
            ( trace_text(T, N, _, _, _),
              N1 < N, N < N2
            ),
            Ns).

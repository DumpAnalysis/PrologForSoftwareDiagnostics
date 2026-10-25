% 27-23.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.21 False Positive Error.
% Program block 23 of the chapter.

% benign_error(?Inv): messages with the invariant
% Inv are marked as errors but are routine.
benign_error(
    "Error: key proxy missing, default used").

% false_positive_error(+Trace, ?N): message N of
% Trace is marked as an error and is benign.
false_positive_error(T, N) :-
    trace_text(T, N, _, _, Text),
    sub_string(Text, 0, _, _, "Error:"),
    invariant(Text, Inv),
    benign_error(Inv).

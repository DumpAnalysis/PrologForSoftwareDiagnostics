% 29-07.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 29. Meta-Interpreters and Explanation: 29.6 Depth-Bounded Interpretation.
% Program block 7 of the chapter.

% blocked_by(?T, ?B): T waits, directly or through
% other threads, for a critical section B owns.
% Deliberately without a visited list.
blocked_by(T, B) :-
    blocks(B, T).
blocked_by(T, B) :-
    blocks(X, T),
    blocked_by(X, B).

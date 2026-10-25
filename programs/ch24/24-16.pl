% 24-16.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 24. Trace Structure: 24.14 Sparse Trace.
% Program block 16 of the chapter.

% threshold(Name, Value): the thresholds of this
% chapter.
threshold(sparse_trace, 1.0).

% message_rate(Set, Rate): Rate is the number of
% messages of Set per second of its span.
message_rate(Set, Rate) :-
    head_message(Set, First),
    tail_message(Set, Last),
    msg(First, T1, _, _, _, _),
    msg(Last, T2, _, _, _, _),
    T2 > T1,
    length(Set, Count),
    Rate is Count / (T2 - T1).

% sparse_trace(Set): the rate of Set is below the
% sparse_trace threshold.
sparse_trace(Set) :-
    message_rate(Set, Rate),
    threshold(sparse_trace, Min),
    Rate < Min.

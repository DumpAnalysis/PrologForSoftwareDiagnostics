% 25-04.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 25. Time: 25.2 Discontinuity.
% Program block 4 of the chapter.

% discontinuity(N, Delta): the gap after message N
% in the trace exceeds the threshold.
discontinuity(N, Delta) :-
    time_delta(N, _, Delta),
    threshold(discontinuity, Min),
    Delta > Min.

% discontinuity(Set, N, Delta): the gap after N
% within the message set Set exceeds the
% threshold.
discontinuity(Set, N, Delta) :-
    time_delta(Set, N, _, Delta),
    threshold(discontinuity, Min),
    Delta > Min.

% thread_discontinuity(TID, N, Delta): a
% discontinuity within the messages of TID.
thread_discontinuity(TID, N, Delta) :-
    thread_messages(TID, Set),
    discontinuity(Set, N, Delta).

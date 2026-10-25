% 25-19.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 25. Time: 25.16 No Activity.
% Program block 19 of the chapter.

% silence(Set, From, To): no message of Set was
% written in the interval From..To, which is
% bounded by messages of Set or the trace ends.
silence(Set, Start, T) :-
    trace_start(Start),
    Set = [First | _],
    time_ms(First, T).
silence(Set, T1, T2) :-
    nextto(N1, N2, Set),
    time_ms(N1, T1),
    time_ms(N2, T2).
silence(Set, T, End) :-
    last(Set, Last),
    time_ms(Last, T),
    trace_end(End).

% no_activity(Set, From, To): a silence of Set
% longer than the no_activity threshold.
no_activity(Set, From, To) :-
    silence(Set, From, To),
    threshold(no_activity, Min),
    To - From > Min.

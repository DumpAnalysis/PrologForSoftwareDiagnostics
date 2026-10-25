% 25-18.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 25. Time: 25.15 Last Activity.
% Program block 18 of the chapter.

% last_activity(TID, N, Age): N is the last
% message of thread TID, written Age ms before the
% trace ended.
last_activity(TID, N, Age) :-
    thread_messages(TID, Set),
    last(Set, N),
    time_ms(N, T),
    trace_end(End),
    Age is End - T.

% print_last_activity: one line per thread, the
% longest silent first.
print_last_activity :-
    forall(order_by([desc(Age)],
                    last_activity(TID, N, Age)),
           print_last(TID, N, Age)).

print_last(TID, N, Age) :-
    msg(N, _, _, _, _, Text),
    truncated(Text, 26, Short),
    format("~d~t~5|~t~d~8| ~t~d~15| ~s~n",
           [TID, N, Age, Short]).

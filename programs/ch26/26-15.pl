% 26-15.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 26. Activities and Threads of Activity: 26.13 Guest Component.
% Program block 15 of the chapter.

% guest_component(Set, C): component C has exactly
% one message in Set, which has at least host_size
% messages.
guest_component(Set, C) :-
    length(Set, Size),
    threshold(host_size, Min),
    Size >= Min,
    aggregate_all(set(C0),
                  ( member(N, Set),
                    msg(N, _, _, _, C0, _) ),
                  Cs),
    member(C, Cs),
    aggregate_all(count,
                  ( member(N, Set),
                    msg(N, _, _, _, C, _) ),
                  1).

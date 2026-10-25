% 26-19.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 26. Activities and Threads of Activity: 26.17 Message Interleave.
% Program block 19 of the chapter.

% message_interleave(From, To, Count, Switches):
% of the Count messages in From..To, Switches
% consecutive pairs are from different threads.
message_interleave(From, To, Count, Switches) :-
    window_messages(From, To, Set),
    length(Set, Count),
    aggregate_all(count,
                  ( nextto(N1, N2, Set),
                    msg(N1, _, _, T1, _, _),
                    msg(N2, _, _, T2, _, _),
                    T1 \== T2 ),
                  Switches).

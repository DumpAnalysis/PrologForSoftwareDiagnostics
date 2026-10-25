% 27-14.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.13 Message Context.
% Program block 14 of the chapter.

% message_context(+N, +K, -Ns): the messages from
% N-K to N+K that exist.
message_context(N, K, Ns) :-
    Lo is N - K,
    Hi is N + K,
    findall(M,
            ( between(Lo, Hi, M),
              msg(M, _, _, _, _, _)
            ),
            Ns).

% thread_context(+N, +K, -Ns): the messages of the
% thread of N within K positions of N on that
% thread.
thread_context(N, K, Ns) :-
    msg(N, _, _, TID, _, _),
    thread_sequence(TID, Seq),
    once(nth0(I, Seq, N)),
    findall(M,
            ( nth0(J, Seq, M),
              abs(J - I) =< K
            ),
            Ns).

% 27-13.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.12 Pivot Message.
% Program block 13 of the chapter.

% pivot_message(+N, ?By, -Ns): Ns are the messages
% that share with message N its thread, its
% component, or a key; By is thread, component,
% or key(Key).
pivot_message(N, thread, Ns) :-
    msg(N, _, _, TID, _, _),
    thread_sequence(TID, Ns).
pivot_message(N, component, Ns) :-
    msg(N, _, _, _, C, _),
    findall(M, msg(M, _, _, _, C, _), Ns).
pivot_message(N, key(Key), Ns) :-
    message_key(N, Key),
    findall(M, message_key(M, Key), Ns).

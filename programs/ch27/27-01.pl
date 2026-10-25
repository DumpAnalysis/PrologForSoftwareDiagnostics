% 27-01.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages.
% Program block 1 of the chapter.

:- [trace1].

% print_messages(+Ns): print message N for each N
% in Ns, with its thread.
print_messages(Ns) :-
    forall(member(N, Ns), print_msg(N)).

print_msg(N) :-
    msg(N, _, _, TID, _, Text),
    format("~t~d~3| ~d ~s~n", [N, TID, Text]).

% text_of(?N, ?Text): the text of message N.
text_of(N, Text) :-
    msg(N, _, _, _, _, Text).

% trace_thread(-TID): TID is a thread of the
% trace; each thread once.
trace_thread(TID) :-
    distinct(TID, msg(_, _, _, TID, _, _)).

% thread_sequence(+TID, -Ns): the numbers of the
% messages of thread TID, in order.
thread_sequence(TID, Ns) :-
    findall(N, msg(N, _, _, TID, _, _), Ns0),
    sort(Ns0, Ns).

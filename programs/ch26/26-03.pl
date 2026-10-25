% 26-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 26. Activities and Threads of Activity: 26.2 Adjoint Thread of Activity.
% Program block 3 of the chapter.

% request_id(N, Request): the text of message N
% mentions request number Request.
request_id(N, Request) :-
    msg(N, _, _, _, _, Text),
    string_lower(Text, Lower),
    string_codes(Lower, Codes),
    phrase(request_mention(Request), Codes).

request_mention(Request) -->
    (   "request "
    ->  integer(Found),
        remainder(_),
        { Request = Found }
    ;   [_],
        request_mention(Request)
    ).

% adjoint(Key, N): message N belongs to the
% adjoint thread selected by Key.
adjoint(component(C), N) :-
    msg(N, _, _, _, C, _).
adjoint(request(R), N) :-
    request_id(N, R).

% adjoint_thread_of_activity(Key, Set): Set is the
% message set of the adjoint thread Key.
adjoint_thread_of_activity(Key, Set) :-
    bagof(N, adjoint(Key, N), Ns),
    sort(Ns, Set).

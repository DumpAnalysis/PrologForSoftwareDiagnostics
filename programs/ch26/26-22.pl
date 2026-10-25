% 26-22.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 26. Activities and Threads of Activity: 26.20 Use Case Trail.
% Program block 22 of the chapter.

% received(R, N), dispatched(R, N, Worker),
% completed(R, N): the lifecycle messages of R.
received(Request, N) :-
    request_id(N, Request),
    msg(N, _, _, _, _, Text),
    sub_string(Text, _, _, _, " received").

dispatched(Request, N, Worker) :-
    request_id(N, Request),
    msg(N, _, _, Worker, _, Text),
    sub_string(Text, _, _, _, " dispatched").

completed(Request, N) :-
    request_id(N, Request),
    msg(N, _, _, _, _, Text),
    sub_string(Text, _, _, _, " completed").

% use_case_trail(Request, Trail): Trail is the set
% of messages serving Request across threads.
use_case_trail(Request, Trail) :-
    received(Request, N0),
    (   dispatched(Request, Start, Worker)
    ->  true
    ;   Start = N0,
        msg(N0, _, _, Worker, _, _)
    ),
    thread_of_activity(Worker, Set),
    append(_, [Start | After], Set),
    take_part(After, Part, _),
    (   completed(Request, End)
    ->  append(Before, [End | _], [Start | Part]),
        append(Before, [End], Segment)
    ;   Segment = [Start | Part]
    ),
    adjoint_thread_of_activity(request(Request),
                               Adjoint),
    ord_union(Adjoint, Segment, Trail).

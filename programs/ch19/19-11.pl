% 19-11.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 19. Exceptions and Faults: 19.9 Stack Overflow (User Mode).
% Program block 11 of the chapter.

% runs(List, Runs): Runs is the list of X-N pairs,
% one per maximal run of N consecutive elements
% equal to X in List.
runs([], []).
runs([X | Xs], [X-N | Runs]) :-
    run_length(Xs, X, 1, N, Rest),
    runs(Rest, Runs).

run_length(Xs, X, N0, N, Rest) :-
    (   Xs = [Y | Xs1],
        Y == X
    ->  N1 is N0 + 1,
        run_length(Xs1, X, N1, N, Rest)
    ;   N = N0,
        Rest = Xs
    ).

% frame_key(Frame, Key): Key is the pair
% Module-Function of the frame/5 term Frame.
frame_key(frame(_, _, M, F, _), M-F).

% stack_trace_signature(TID, Signature): the keys
% of the frames of TID, top frame first.
stack_trace_signature(TID, Signature) :-
    stack_trace(TID, Frames),
    maplist(frame_key, Frames, Signature).

% frame_regularity(TID, Key, Count): the signature
% of TID has a run of Count frames with Key, Count
% at least the threshold.
frame_regularity(TID, Key, Count) :-
    thread(TID, _),
    stack_trace_signature(TID, Signature),
    runs(Signature, Runs),
    member(Key-Count, Runs),
    threshold(frame_run, Min),
    Count >= Min.

% stack_depth(TID, Depth): the stack trace of TID
% has Depth frames.
stack_depth(TID, Depth) :-
    stack_trace(TID, Frames),
    length(Frames, Depth).

% stack_overflow(TID, Finding): Finding is the
% evidence that TID overflowed its stack, by the
% status code, or the suspicion of it, by depth
% and a run at least overflow_run long.
stack_overflow(TID, Finding) :-
    exception_record(TID, 0xc00000fd, Addr),
    Name = 'Stack Overflow (User Mode)',
    Code = 0xc00000fd,
    Facts = [exception_record(TID, Code, Addr)],
    Finding = evidence(Name, TID, Facts).
stack_overflow(TID, Finding) :-
    thread(TID, PID),
    stack_depth(TID, Depth),
    threshold(stack_depth, MinDepth),
    Depth >= MinDepth,
    frame_regularity(TID, Key, Count),
    threshold(overflow_run, MinRun),
    Count >= MinRun,
    Name = 'Stack Overflow (User Mode)',
    Grounds = [ thread(TID, PID),
                stack_depth(TID, Depth),
                threshold(stack_depth, MinDepth),
                frame_regularity(TID, Key, Count),
                threshold(overflow_run, MinRun)
              ],
    Finding = suspected(Name, TID, Grounds).

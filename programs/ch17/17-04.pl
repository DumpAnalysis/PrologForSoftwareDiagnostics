% 17-04.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 17. The Pattern as a Predicate: 17.4 Thresholds as Facts.
% Program block 4 of the chapter.

% handle_leak(Type, E): handles of Type exceed the
% threshold; a Handle Leak candidate.
handle_leak(Type, E) :-
    handle_count(PID, Type, Count),
    threshold(handle_count, Max),
    Count > Max,
    E = evidence('Handle Leak', Type,
        [ handle_count(PID, Type, Count),
          threshold(handle_count, Max)
        ]).

handle_leak(Type) :-
    handle_leak(Type, _).

% null_pointer_data(TID, E): TID faulted reading
% or writing an address in the null page.
null_pointer_data(TID, E) :-
    exception_record(TID, Code, Addr),
    Code =:= 0xc0000005,
    exception_info(TID, access, Access),
    Access \== execute,
    exception_info(TID, target, Target),
    threshold(null_page, Limit),
    Target < Limit,
    E = evidence('NULL Pointer (Data)', TID,
        [ exception_record(TID, Code, Addr),
          exception_info(TID, access, Access),
          exception_info(TID, target, Target),
          threshold(null_page, Limit)
        ]).

null_pointer_data(TID) :-
    null_pointer_data(TID, _).

% frame_function(Frame, F): F is the function of
% the frame/5 term Frame.
frame_function(frame(_, _, _, F, _), F).

% frame_runs(Frames, Runs): Runs is the list of
% maximal runs of consecutive frames of Frames
% that name one function, each run a list.
frame_runs([], []).
frame_runs([Frame | Frames],
           [[Frame | Run] | Runs]) :-
    frame_function(Frame, F),
    same_function(Frames, F, Run, Rest),
    frame_runs(Rest, Runs).

% same_function(Frames, F, Run, Rest): Run is the
% longest prefix of Frames whose frames name F;
% Rest is what follows it.
same_function(Frames, F, Run, Rest) :-
    (   Frames = [Frame | Frames1],
        frame_function(Frame, F)
    ->  Run = [Frame | Run1],
        same_function(Frames1, F, Run1, Rest)
    ;   Run = [],
        Rest = Frames
    ).

% frame_regularity(TID, E): the longest run of
% consecutive frames of TID naming one function is
% at least the threshold long; the frames of the
% run are the evidence.
frame_regularity(TID, E) :-
    thread(TID, _),
    findall(frame(TID, N, M, F, O),
            frame(TID, N, M, F, O), Frames0),
    sort(2, @=<, Frames0, Frames),
    frame_runs(Frames, Runs),
    aggregate_all(max(C, R),
                  ( member(R, Runs),
                    length(R, C)
                  ),
                  max(Count, Run)),
    threshold(frame_repeats, Min),
    Count >= Min,
    append(Run, [threshold(frame_repeats, Min)],
           Facts),
    E = evidence('Frame Regularity', TID, Facts).

frame_regularity(TID) :-
    frame_regularity(TID, _).

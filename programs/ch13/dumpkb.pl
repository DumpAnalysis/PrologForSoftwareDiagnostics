% dumpkb.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 13. Programs, Modules, Files, and Tooling: 13.1 Modules.
% Program block 1 of the chapter.

:- module(dumpkb,
          [ stack_trace/2,
            top_frame/2,
            thread_modules/2,
            spiking_thread/1,
            blocked_on/2
          ]).

:- [dump1].

%!  stack_trace(+TID, -Frames) is det.
%
%   Frames is the list of frame/5 terms of thread
%   TID in frame order, [] if TID has no frames.
stack_trace(TID, Frames) :-
    frames_from(TID, 0, Frames).

frames_from(TID, N, Frames) :-
    (   frame(TID, N, M, F, O)
    ->  Frames = [frame(TID, N, M, F, O) | Rest],
        succ(N, N1),
        frames_from(TID, N1, Rest)
    ;   Frames = []
    ).

%!  top_frame(?TID, ?Function) is nondet.
%
%   Function is the function of frame 0 of TID.
top_frame(TID, Function) :-
    frame(TID, 0, _, Function, _).

%!  thread_modules(+TID, -Modules) is det.
%
%   Modules is the set of modules on the stack
%   trace of TID, in standard order.
thread_modules(TID, Modules) :-
    stack_trace(TID, Frames),
    maplist(frame_module, Frames, List),
    sort(List, Modules).

frame_module(frame(_, _, M, _, _), M).

%!  spiking_thread(?TID) is nondet.
%
%   TID used at least a quarter of the CPU time
%   of all threads of the dump.
spiking_thread(TID) :-
    aggregate_all(sum(U + K),
                  thread_time(_, U, K), Total),
    thread_time(TID, User, Kernel),
    (User + Kernel) * 4 >= Total.

%!  blocked_on(?TID, ?Owner) is nondet.
%
%   TID waits for a critical section that thread
%   Owner holds.
blocked_on(TID, Owner) :-
    waits_for(TID, critical_section, Addr),
    critical_section(Addr, Owner, _, _),
    Owner =\= 0.

% 13-11.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 13. Programs, Modules, Files, and Tooling: 13.5 Debugging, Assertions, and Unit Tests.
% Program block 11 of the chapter.

:- use_module(library(plunit)).
:- set_prolog_flag(verbose, normal).

:- begin_tests(stacks).

test(faulting_frame, true(F == 'Buffer::Copy')) :-
    top_frame(109, F).

test(depth_of_107, true(N == 14)) :-
    stack_trace(107, Frames),
    length(Frames, N).

test(no_such_thread, true(Frames == [])) :-
    stack_trace(999, Frames).

test(pool_threads, all(T == [105, 106])) :-
    top_frame(T, 'NtWaitForWorkViaWorkerFactory').

test(deep_thread_fails, fail) :-
    deep_thread(105, _).

test(top_frame_is_nondet, nondet) :-
    top_frame(_, 'NtWaitForAlertByThreadId').

:- end_tests(stacks).

% 13-12.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 13. Programs, Modules, Files, and Tooling: 13.5 Debugging, Assertions, and Unit Tests.
% Program block 12 of the chapter.

:- begin_tests(broken).

test(wrong_depth, true(N == 7)) :-
    stack_trace(107, Frames),
    length(Frames, N).

test(wrong_type) :-
    _ is foo + 1.

test(bottom_frame, nondet) :-
    top_frame(_, 'RtlUserThreadStart').

:- end_tests(broken).

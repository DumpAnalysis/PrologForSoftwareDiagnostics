% 26-12.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 26. Activities and Threads of Activity: 26.11 Resume Activity.
% Program block 12 of the chapter.

% resume_activity(TID, N, Gap): message N of
% thread TID follows the thread's previous message
% after a gap of Gap ms above the threshold.
resume_activity(TID, N, Gap) :-
    thread_of_activity(TID, Set),
    nextto(Previous, N, Set),
    time_ms(Previous, T1),
    time_ms(N, T2),
    Gap is T2 - T1,
    threshold(resume, Min),
    Gap > Min.

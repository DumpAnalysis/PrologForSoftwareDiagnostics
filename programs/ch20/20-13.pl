% 20-13.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 20. Synchronization Patterns: 20.11 Waiting Thread Time.
% Program block 13 of the chapter.

% wait_time(TID, Ms): TID has been waiting for Ms
% milliseconds. An extension of the schema.
wait_time(100, 20).
wait_time(101, 9800).
wait_time(103, 12400).
wait_time(104, 12380).
wait_time(105, 61000).
wait_time(106, 59500).
wait_time(108, 4900).

% waiting_thread_time(-TID, -Ms): the waiting
% threads with their wait times, longest first.
waiting_thread_time(TID, Ms) :-
    order_by([desc(Ms)], wait_time(TID, Ms)).

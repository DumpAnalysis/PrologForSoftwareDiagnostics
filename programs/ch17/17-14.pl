% 17-14.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 17. The Pattern as a Predicate: 17.10 Testing Recognizers.
% Program block 14 of the chapter.

:- begin_tests(wrong_claims).

test(main_thread_spikes) :-
    spiking_thread(100).

test(share, true(S =:= 50)) :-
    cpu_share(102, S).

:- end_tests(wrong_claims).

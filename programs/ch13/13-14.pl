% 13-14.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 13. Programs, Modules, Files, and Tooling: 13.7 Diagnostic Use.
% Program block 14 of the chapter.

:- use_module(library(plunit)).

:- begin_tests(patterns).

test(spiking_threads, all(T == [102, 107])) :-
    spiking_thread(T).

test(main_thread_not_spiking, fail) :-
    spiking_thread(100).

test(deadlock_pair, true(O == 104)) :-
    blocked_on(103, O).

test(blocked_threads, all(T-O == [101-103,
                                  103-104,
                                  104-103])) :-
    blocked_on(T, O).

test(faulting_modules, true(Ms == [appserver,
                                  dbclient,
                                  kernel32,
                                  ntdll,
                                  ucrtbase])) :-
    thread_modules(109, Ms).

test(idle_pool_thread, true(Ms == [kernel32,
                                  ntdll])) :-
    thread_modules(105, Ms).

:- end_tests(patterns).

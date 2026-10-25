% 11-07.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 11. The Dynamic Database, Global State, and Tabling: 11.6 Tabling.
% Program block 7 of the chapter.

% fib(N, F): F is the Nth Fibonacci number.
fib(N, F) :-
    (   N < 2
    ->  F = N
    ;   N1 is N - 1,
        N2 is N - 2,
        fib(N1, F1),
        fib(N2, F2),
        F is F1 + F2
    ).

% tfib(N, F): as fib/2, tabled.
:- table tfib/2.
tfib(N, F) :-
    (   N < 2
    ->  F = N
    ;   N1 is N - 1,
        N2 is N - 2,
        tfib(N1, F1),
        tfib(N2, F2),
        F is F1 + F2
    ).

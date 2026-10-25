% 31-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 31. Integration: Scripts, Embedding, and Debugger Extensions: 31.3 CSV.
% Program block 3 of the chapter.

:- use_module(library(csv)).

% thread_rows(-Rows): CPU times as CSV rows with a
% header row.
thread_rows([Header|Rows]) :-
    Header = row(tid, user_ms, kernel_ms),
    findall(row(T, U, K), thread_time(T, U, K),
            Rows).

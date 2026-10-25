% deltas.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 13. Programs, Modules, Files, and Tooling: 13.2 Programs and Scripts.
% Program block 5 of the chapter.

#!/usr/bin/env swipl
% deltas.pl: print the Time Delta anomalies of a
% software trace stored as CSV.

:- use_module(library(main)).
:- use_module(library(option)).
:- use_module(library(csv)).

% stop the collector thread, so that the exit of
% a short run cannot race it (Section 31.1)
:- set_prolog_gc_thread(false).
:- initialization(main, main).

main(Argv) :-
    argv_options(Argv, [File], Options),
    option(threshold(Min), Options, 1.0),
    csv_read_file(File, Rows, [functor(msg)]),
    report_deltas(Rows, Min).

% report_deltas(Rows, Min): print each pair of
% adjacent rows whose time difference is >= Min.
report_deltas([], _).
report_deltas([Row | Rows], Min) :-
    report_deltas(Rows, Row, Min).

report_deltas([], _, _).
report_deltas([Row | Rows], Prev, Min) :-
    Prev = msg(N1, T1, _, _, _),
    Row = msg(N2, T2, Th, C, Tx),
    Delta is T2 - T1,
    (   Delta >= Min
    ->  format("~w -> ~w: ~3f s (~w, ~w)~n",
               [N1, N2, Delta, Th, C]),
        format("    ~w~n", [Tx])
    ;   true
    ),
    report_deltas(Rows, Row, Min).

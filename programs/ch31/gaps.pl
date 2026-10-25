% gaps.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 31. Integration: Scripts, Embedding, and Debugger Extensions: 31.1 Command-Line Tools.
% Program block 1 of the chapter.

:- use_module(library(main)).
:- set_prolog_gc_thread(false).
:- initialization(main, main).

% opt_type(Opt, Name, Type)
opt_type(threshold, threshold, float).
opt_type(t, threshold, float).
opt_type(csv, csv, boolean).

opt_help(threshold, "Minimum gap in seconds").
opt_help(csv, "Comma-separated output").
opt_help(help(usage), " -- trace.pl [options]").

main(Argv) :-
    argv_options(Argv, [File], Options),
    option(threshold(Min), Options, 1.0),
    option(csv(CSV), Options, false),
    consult(File),
    forall(( gap(N1, N2, Gap), Gap > Min ),
           report(CSV, N1, N2, Gap)).

% gap(?N1, -N2, -Gap): time between consecutive
% messages.
gap(N1, N2, Gap) :-
    msg(N1, T1, _, _, _, _),
    N2 is N1 + 1,
    msg(N2, T2, _, _, _, _),
    Gap is T2 - T1.

report(false, N1, N2, Gap) :-
    format("~d -> ~d: ~3f s~n", [N1, N2, Gap]).
report(true, N1, N2, Gap) :-
    format("~d,~d,~3f~n", [N1, N2, Gap]).

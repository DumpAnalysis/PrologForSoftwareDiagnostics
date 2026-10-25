% 17-13.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 17. The Pattern as a Predicate: 17.10 Testing Recognizers.
% Program block 13 of the chapter.

:- use_module(library(plunit)).

:- begin_tests(dump1_patterns).

test(spiking, all(T == [102, 107])) :-
    spiking_thread(T).

test(not_spiking, fail) :-
    spiking_thread(100).

test(deadlock, [nondet, true(P == 103-104)]) :-
    deadlock(P).

test(null_pointer, T == 109) :-
    null_pointer_data(T).

test(chains, all(C == [[101, 103, 104, 103],
                       [103, 104, 103],
                       [104, 103, 104]])) :-
    wait_chain(C).

test(instance_count, N == 16) :-
    pattern_instances(Es),
    length(Es, N).

test(evidence_ground) :-
    pattern_instances(Es),
    maplist(ground, Es).

test(evidence_holds) :-
    pattern_instances(Es),
    maplist(holds, Es).

test(deadlock_entailed, [nondet]) :-
    deadlock(T1-T2, E),
    leaves(E, Gs),
    entails(Gs,
            ( waits_for(T1, critical_section, A1),
              critical_section(A1, T2, _, _),
              waits_for(T2, critical_section, A2),
              critical_section(A2, T1, _, _) )).

:- end_tests(dump1_patterns).

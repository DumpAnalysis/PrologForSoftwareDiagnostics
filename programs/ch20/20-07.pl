% 20-07.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 20. Synchronization Patterns: 20.4 Deadlock (Critical Sections).
% Program block 7 of the chapter.

% fact_edge(Facts, W, O): the list Facts alone
% says that W waits for an object that O holds.
fact_edge(Facts, W, O) :-
    member(waits_for(W, critical_section, A),
           Facts),
    member(critical_section(A, O, _, _), Facts).
fact_edge(Facts, W, O) :-
    member(waits_for_object(W, mutant, H), Facts),
    member(mutant(H, O, _), Facts).
fact_edge(Facts, W, O) :-
    member(waits_for_object(W, thread, O), Facts).

% cycle_entailed(Facts, Cycle): Facts alone entail
% that each thread of Cycle waits for an object
% the next holds, and the last for the first.
cycle_entailed(Facts, Cycle) :-
    Cycle = [First | _],
    append(Cycle, [First], Closed),
    forall(nextto(W, O, Closed),
           fact_edge(Facts, W, O)).

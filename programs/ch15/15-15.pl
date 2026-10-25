% 15-15.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 15. Memory Dumps as Knowledge Bases: 15.5 Unknowns and Provenance.
% Program block 15 of the chapter.

% without_facts(Pattern, Goal): call Goal once
% with every fact matching Pattern retracted; the
% facts are restored afterwards, whether Goal
% succeeds, fails, or raises.
without_facts(Pattern, Goal) :-
    findall(Pattern, Pattern, Facts),
    setup_call_cleanup(
        retractall(Pattern),
        once(Goal),
        maplist(assertz, Facts)).

% with_fact(Fact, Goal): call Goal once with Fact
% added; Fact is retracted afterwards.
with_fact(Fact, Goal) :-
    setup_call_cleanup(
        assertz(Fact),
        once(Goal),
        retract(Fact)).

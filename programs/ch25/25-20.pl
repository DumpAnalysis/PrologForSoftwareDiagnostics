% 25-20.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 25. Time: 25.17 Blackout.
% Program block 20 of the chapter.

% blackout(From-To): no message was written
% between From and To, an interval longer than the
% blackout threshold.
blackout(From-To) :-
    time_delta(N, Next, Delta),
    threshold(blackout, Min),
    Delta > Min,
    time_ms(N, From),
    time_ms(Next, To).

% blackout(Interval, Evidence): the explainer
% form, with the facts the instance rests on.
blackout(From-To, evidence('Blackout', From-To,
                           Facts)) :-
    time_delta(N, Next, Delta),
    threshold(blackout, Min),
    Delta > Min,
    time_ms(N, From),
    time_ms(Next, To),
    Facts = [time_delta(N, Next, Delta),
             threshold(blackout, Min)].

% print_evidence(Evidence): the instance and each
% supporting fact as a clause.
print_evidence(evidence(Pattern, Instance, Fs)) :-
    format("~w: ~w~n", [Pattern, Instance]),
    forall(member(Fact, Fs),
           portray_clause(Fact)).

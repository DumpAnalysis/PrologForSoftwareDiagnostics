% 25-17.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 25. Time: 25.14 Milestones.
% Program block 17 of the chapter.

% milestone_prefix(Prefix): the text a milestone
% message begins with.
milestone_prefix("Service starting").
milestone_prefix("Worker pool started").
milestone_prefix("Unhandled exception").
milestone_prefix("Service stopping").

% milestone(N): message N is a milestone.
milestone(N) :-
    msg(N, _, _, _, _, Text),
    milestone_prefix(Prefix),
    sub_string(Text, 0, _, _, Prefix).

% milestones(Ns): the message set of milestones.
milestones(Ns) :-
    findall(N, milestone(N), Ns0),
    sort(Ns0, Ns).

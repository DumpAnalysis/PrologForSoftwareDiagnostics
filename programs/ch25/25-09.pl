% 25-09.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 25. Time: 25.6 Relative Density.
% Program block 9 of the chapter.

% relative_density(TemplateA, TemplateB, From, To,
% Ratio): Ratio is the number of messages matching
% TemplateA per message matching TemplateB in the
% window.
relative_density(TemplateA, TemplateB, From, To,
                 Ratio) :-
    window_messages(From, To, Set),
    TemplateA = msg(NA, _, _, _, _, _),
    TemplateB = msg(NB, _, _, _, _, _),
    aggregate_all(count,
                  ( member(NA, Set), TemplateA ),
                  CountA),
    aggregate_all(count,
                  ( member(NB, Set), TemplateB ),
                  CountB),
    CountB > 0,
    Ratio is CountA / CountB.

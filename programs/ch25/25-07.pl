% 25-07.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 25. Time: 25.4.1 A boundary check: the window width.
% Program block 7 of the chapter.

% statement_density(Template, From, To, Density):
% Density is the share of the messages in the
% window that unify with Template.
statement_density(Template, From, To, Density) :-
    window_messages(From, To, Set),
    length(Set, Total),
    Total > 0,
    Template = msg(N, _, _, _, _, _),
    aggregate_all(count,
                  ( member(N, Set), Template ),
                  Count),
    Density is Count / Total.

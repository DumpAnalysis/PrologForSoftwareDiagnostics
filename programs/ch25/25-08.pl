% 25-08.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 25. Time: 25.5 Density Distribution.
% Program block 8 of the chapter.

% density_distribution(Template, Width, Dist):
% Dist is the list of From-Density pairs for the
% non-empty windows of Width seconds.
density_distribution(Template, Width, Dist) :-
    findall(From-Density,
            window_density(Template, Width, From,
                           Density),
            Dist).

window_density(Template, Width, From, Density) :-
    window(Width, From, To),
    statement_density(Template, From, To,
                      Density).

% print_distribution(Dist): one line per window.
print_distribution(Dist) :-
    forall(member(From-Density, Dist),
           ( Stars is round(20 * Density),
             format("~t~d~3| ~t~2f~9| ~*c~n",
                    [From, Density, Stars, 0'*])
           )).

% 05-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 5. Lists and Recursion: 5.2 Recursion over Lists.
% Program block 3 of the chapter.

% without_module(Ms, M, Rest): Rest is Ms without
% the occurrences of module M.
without_module([], _, []).
without_module([M | Ms], M, Rest) :-
    without_module(Ms, M, Rest).
without_module([M0 | Ms], M, [M0 | Rest]) :-
    M0 \== M,
    without_module(Ms, M, Rest).

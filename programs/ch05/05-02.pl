% 05-02.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 5. Lists and Recursion: 5.2 Recursion over Lists.
% Program block 2 of the chapter.

% list_append(Xs, Ys, Zs): Zs is the concatenation
% of Xs and Ys.
list_append([], Ys, Ys).
list_append([X | Xs], Ys, [X | Zs]) :-
    list_append(Xs, Ys, Zs).

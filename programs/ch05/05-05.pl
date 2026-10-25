% 05-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 5. Lists and Recursion: 5.4 Accumulators and Tail Recursion.
% Program block 5 of the chapter.

% naive_reverse(Xs, Ys): Ys is Xs reversed.
naive_reverse([], []).
naive_reverse([X | Xs], Ys) :-
    naive_reverse(Xs, Zs),
    list_append(Zs, [X], Ys).

% 05-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 5. Lists and Recursion: 5.4 Accumulators and Tail Recursion.
% Program block 6 of the chapter.

% reverse_acc(Xs, Acc, Ys): Ys is Xs reversed,
% followed by Acc.
reverse_acc([], Ys, Ys).
reverse_acc([X | Xs], Acc, Ys) :-
    reverse_acc(Xs, [X | Acc], Ys).

% list_reverse(Xs, Ys): Ys is Xs reversed.
list_reverse(Xs, Ys) :-
    reverse_acc(Xs, [], Ys).

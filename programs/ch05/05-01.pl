% 05-01.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 5. Lists and Recursion: 5.2 Recursion over Lists.
% Program block 1 of the chapter.

% list_member(X, List): X is an element of List.
list_member(X, [X | _]).
list_member(X, [_ | T]) :-
    list_member(X, T).

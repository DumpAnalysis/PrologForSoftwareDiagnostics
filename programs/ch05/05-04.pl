% 05-04.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 5. Lists and Recursion: 5.2 Recursion over Lists.
% Program block 4 of the chapter.

% leading_run(List, X, Run): Run is the longest
% prefix of List all of whose elements are X.
leading_run([], _, []).
leading_run([X | Xs], X, [X | Run]) :-
    leading_run(Xs, X, Run).
leading_run([Y | _], X, []) :-
    Y \== X.

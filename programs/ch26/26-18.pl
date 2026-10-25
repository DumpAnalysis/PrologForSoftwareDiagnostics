% 26-18.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 26. Activities and Threads of Activity: 26.16 Error Distribution.
% Program block 18 of the chapter.

% error_dimension(Dim, N, Value): the value of
% message N along Dim, with second as the integer
% part of its time.
error_dimension(thread, N, TID) :-
    msg(N, _, _, TID, _, _).
error_dimension(component, N, C) :-
    msg(N, _, _, _, C, _).
error_dimension(second, N, S) :-
    msg(N, T, _, _, _, _),
    S is floor(T).

% error_distribution(Dim, Dist): Dist is the list
% of Value-Count pairs of error messages along
% Dim.
error_distribution(Dim, Dist) :-
    findall(V-N,
            ( error_message(N),
              error_dimension(Dim, N, V) ),
            Pairs),
    keysort(Pairs, Sorted),
    group_pairs_by_key(Sorted, Groups),
    maplist(count_group, Groups, Dist).

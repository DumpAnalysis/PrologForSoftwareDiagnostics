% 26-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 26. Activities and Threads of Activity: 26.4 Activity Theatre.
% Program block 5 of the chapter.

% window_messages(From, To, Set): the messages
% with From =< Time < To, in seconds.
window_messages(From, To, Set) :-
    findall(N,
            ( msg(N, T, _, _, _, _),
              T >= From, T < To ),
            Ns),
    sort(Ns, Set).

% activity_theatre(From, To, Actors): Actors is
% the list of TID-Count pairs of the threads with
% messages in the interval.
activity_theatre(From, To, Actors) :-
    window_messages(From, To, Set),
    findall(TID-N,
            ( member(N, Set),
              msg(N, _, _, TID, _, _) ),
            Pairs),
    keysort(Pairs, Sorted),
    group_pairs_by_key(Sorted, Groups),
    maplist(count_group, Groups, Actors).

count_group(Key-Ns, Key-Count) :-
    length(Ns, Count).

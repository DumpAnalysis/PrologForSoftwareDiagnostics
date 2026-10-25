% 26-09.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 26. Activities and Threads of Activity: 26.8 Sheaf of Activities.
% Program block 9 of the chapter.

% sheaf_of_activities(From, To, Sections):
% Sections is the list of TID-Set pairs of the
% threads with messages in From..To.
sheaf_of_activities(From, To, Sections) :-
    window_messages(From, To, Set),
    findall(TID-N,
            ( member(N, Set),
              msg(N, _, _, TID, _, _) ),
            Pairs),
    keysort(Pairs, Sorted),
    group_pairs_by_key(Sorted, Sections).

% restriction(Sections, From, To, Restricted): the
% sections cut down to the interval From..To.
restriction(Sections, From, To, Restricted) :-
    window_messages(From, To, Window),
    findall(TID-Part,
            ( member(TID-Ns, Sections),
              ord_intersection(Ns, Window, Part),
              Part \== [] ),
            Restricted).

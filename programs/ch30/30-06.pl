% 30-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 30. Scale and Performance: 30.6 Distinct Values and library(nb_set).
% Program block 6 of the chapter.

:- use_module(library(nb_set)).

% threads_nb(-TIDs): distinct threads via nb_set.
threads_nb(TIDs) :-
    empty_nb_set(Set),
    forall(smsg(_, _, _, TID, _, _),
           add_nb_set(TID, Set)),
    nb_set_to_list(Set, TIDs).

% threads_setof(-TIDs): the same via setof/3.
threads_setof(TIDs) :-
    setof(TID, N^T^P^C^X^smsg(N, T, P, TID, C, X),
          TIDs).

% first_message_of_each(-Ns): the number of the
% first message of every thread, in one pass.
first_message_of_each(Ns) :-
    empty_nb_set(Seen),
    findall(N, ( smsg(N, _, _, TID, _, _),
                 add_nb_set(TID, Seen, true) ),
            Ns).

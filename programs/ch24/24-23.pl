% 24-23.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 24. Trace Structure: 24.21 Working Set.
% Program block 23 of the chapter.

% working_set(Set, Components): Components is the
% set of components with a message in Set.
working_set(Set, Components) :-
    aggregate_all(set(C),
                  ( member(N, Set),
                    msg(N, _, _, _, C, _) ),
                  Components).

% print_working_sets(Frames): one line per frame
% with its message range and working set.
print_working_sets(Frames) :-
    forall(member(Frame, Frames),
           print_working_set(Frame)).

print_working_set(I-Set) :-
    working_set(Set, Cs),
    Set = [First | _],
    last(Set, Last),
    atomic_list_concat(Cs, ' ', Line),
    format("~t~d~2| ~t~d~6|-~d~t~13|~a~n",
           [I, First, Last, Line]).

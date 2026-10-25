% 10-08.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 10. Higher-Order Predicates and Libraries: 10.6 Association Lists.
% Program block 8 of the chapter.

% count_into(Key, A0, A): A is A0 with the count
% of Key increased by one, or set to 1 if absent.
count_into(Key, A0, A) :-
    (   get_assoc(Key, A0, N0)
    ->  N is N0 + 1
    ;   N = 1
    ),
    put_assoc(Key, A0, N, A).

% module_counts(Counts): Counts is the list of
% Module-N pairs, N the number of frames in Module
% over all stack traces of the dump, by module.
module_counts(Counts) :-
    findall(M, frame(_, _, M, _, _), Ms),
    empty_assoc(A0),
    foldl(count_into, Ms, A0, A),
    assoc_to_list(A, Counts).

% 24-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 24. Trace Structure: 24.5 Trace Partition.
% Program block 6 of the chapter.

% trace_partition(Dim, Partition): Partition is
% the list of Value-Set pairs dividing the trace
% by its values along Dim.
trace_partition(Dim, Partition) :-
    findall(V-N, dimension_value(Dim, N, V),
            Pairs),
    keysort(Pairs, Sorted),
    group_pairs_by_key(Sorted, Partition).

% print_partition(Partition): one line per part
% with its size and first and last message.
print_partition(Partition) :-
    forall(member(Part, Partition),
           print_part(Part)).

print_part(V-Set) :-
    length(Set, Len),
    Set = [First | _],
    last(Set, Last),
    format("~w~t~14|~t~d~4+~t~d~5+~t~d~5+~n",
           [V, Len, First, Last]).

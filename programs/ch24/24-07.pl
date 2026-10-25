% 24-07.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 24. Trace Structure: 24.5 Trace Partition.
% Program block 7 of the chapter.

% exhaustive(Sets): the union of Sets is the whole
% trace.
exhaustive(Sets) :-
    foldl(ord_union, Sets, [], Union),
    message_set(msg(_, _, _, _, _, _), Union).

% disjoint(Sets): no two sets in Sets share a
% message.
disjoint([]).
disjoint([Set | Sets]) :-
    foldl(ord_union, Sets, [], Rest),
    ord_disjoint(Set, Rest),
    disjoint(Sets).

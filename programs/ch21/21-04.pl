% 21-04.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 21. Memory, Heaps, Handles, and Leaks: 21.2 Handle Leak.
% Program block 4 of the chapter.

% handle_leak(Type): the count of handles of Type
% exceeds the analyst's limit for one type.
handle_leak(Type) :-
    handle_count(_, Type, Count),
    threshold(handle_type_count, Max),
    Count > Max.

% handle_share(Type, Share): the share of the
% process's handles that are of Type.
handle_share(Type, Share) :-
    handle_count(PID, Type, Count),
    aggregate_all(sum(C), handle_count(PID, _, C),
                  Total),
    Share is Count / Total.

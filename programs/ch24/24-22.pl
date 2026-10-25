% 24-22.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 24. Trace Structure: 24.20 Trace Viewpoints.
% Program block 22 of the chapter.

% trace_viewpoint(Dim, Set, View): View is the
% list of Value-Subset pairs dividing the message
% set Set by its values along Dim.
trace_viewpoint(Dim, Set, View) :-
    findall(V-N,
            ( member(N, Set),
              dimension_value(Dim, N, V) ),
            Pairs),
    keysort(Pairs, Sorted),
    group_pairs_by_key(Sorted, View).

% print_view(View): each part under its value.
print_view(View) :-
    forall(member(V-Ns, View),
           ( format("~w~n", [V]),
             print_messages(Ns) )).

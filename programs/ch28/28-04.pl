% 28-04.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 28. Sequences, Motifs, and Correlation: 28.3 Macrofunction.
% Program block 4 of the chapter.

% open_close(?Open, ?Close): Open begins and Close
% ends a bracketed activity.
open_close(dispatched, completed).
open_close(query_start, query_end).
open_close(build_start, build_end).

% ev(+N, ?Token): the bracket token of message N:
% open for a kind that begins a bracket, close for
% one that ends it, leaf for any other.
ev(N, Token) :-
    kind(N, K),
    (   open_close(K, _)
    ->  Token = open(K, N)
    ;   open_close(K0, K)
    ->  Token = close(K0, N)
    ;   Token = leaf(K, N)
    ).

% macrofunction(+TID, -Trees): the nesting forest
% of thread TID's activities.
macrofunction(TID, Trees) :-
    thread_sequence(TID, Ns),
    maplist(ev, Ns, Events),
    phrase(forest(Trees), Events).

forest([T|Ts]) --> tree(T), forest(Ts).
forest([]) --> [].

tree(node(K, N, Children)) -->
    [open(K, N)],
    forest(Children),
    [close(K, _)].
tree(leaf(K, N)) -->
    [leaf(K, N)].

% print_forest(+Trees, +Indent): print the forest
% with two spaces of indentation per level.
print_forest(Trees, Indent) :-
    forall(member(T, Trees),
           print_tree(T, Indent)).

print_tree(leaf(K, N), Indent) :-
    format("~*c~a ~d~n", [Indent, 0' , K, N]).
print_tree(node(K, N, Children), Indent) :-
    format("~*c~a ~d~n", [Indent, 0' , K, N]),
    Deeper is Indent + 2,
    print_forest(Children, Deeper).

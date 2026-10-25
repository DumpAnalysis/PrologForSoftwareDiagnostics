% 13-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 13. Programs, Modules, Files, and Tooling: 13.3 Reading and Writing Files.
% Program block 6 of the chapter.

% file_functors(File, Pairs): Pairs lists, in
% standard order, the Name/Arity of each clause
% head in File with its number of clauses.
file_functors(File, Pairs) :-
    setup_call_cleanup(
        open(File, read, S),
        read_functors(S, Fs),
        close(S)),
    msort(Fs, Sorted),
    clumped(Sorted, Pairs).

read_functors(S, Fs) :-
    read_term(S, T, []),
    (   T == end_of_file
    ->  Fs = []
    ;   T = (:- _)
    ->  read_functors(S, Fs)
    ;   functor(T, Name, Arity),
        Fs = [Name/Arity | Rest],
        read_functors(S, Rest)
    ).

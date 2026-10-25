% 30-10.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 30. Scale and Performance: 30.11 Fact Files and Quick-Load Files.
% Program block 10 of the chapter.

% write_facts(+File): the synthetic trace as facts
% of tmsg/6, so that loading it does not redefine
% the dynamic smsg/6.
write_facts(File) :-
    setup_call_cleanup(
        open(File, write, S),
        forall(smsg(N, T, P, TID, C, Text),
               portray_clause(S,
                   tmsg(N, T, P, TID, C, Text))),
        close(S)).

% count_terms(+File, -N): clauses in a fact file,
% read one at a time.
count_terms(File, N) :-
    setup_call_cleanup(
        open(File, read, S),
        count_terms(S, 0, N),
        close(S)).

count_terms(S, N0, N) :-
    read_term(S, Term, []),
    (   Term == end_of_file
    ->  N = N0
    ;   N1 is N0 + 1,
        count_terms(S, N1, N)
    ).

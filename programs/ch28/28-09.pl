% 28-09.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 28. Sequences, Motifs, and Correlation: 28.8 Quotient Trace.
% Program block 9 of the chapter.

% quotient_trace(-Classes): the message numbers
% grouped into Kind-Members classes.
quotient_trace(Classes) :-
    findall(K-N, kind(N, K), Pairs),
    keysort(Pairs, Sorted),
    group_pairs_by_key(Sorted, Classes).

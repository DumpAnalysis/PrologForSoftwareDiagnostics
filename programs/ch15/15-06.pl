% 15-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 15. Memory Dumps as Knowledge Bases: 15.3 From Debugger Output to Facts.
% Program block 6 of the chapter.

% read_facts(File, Facts): Facts are the terms of
% File, in order.
read_facts(File, Facts) :-
    setup_call_cleanup(
        open(File, read, S),
        read_terms(S, Facts),
        close(S)).

read_terms(S, Facts) :-
    read_term(S, Term, []),
    (   Term == end_of_file
    ->  Facts = []
    ;   Facts = [Term | Rest],
        read_terms(S, Rest)
    ).

% frames_agree(Log, TID, File): File holds one
% fact per frame line of TID in Log, and those
% facts are exactly the frame/5 facts of TID in
% the loaded knowledge base, each side counted
% with repetitions.
frames_agree(Log, TID, File) :-
    aggregate_all(count, log_line(Log, _, _), In),
    read_facts(File, Written),
    length(Written, In),
    findall(frame(TID, N, M, F, O),
            frame(TID, N, M, F, O), Loaded),
    msort(Written, Canonical),
    msort(Loaded, Canonical).

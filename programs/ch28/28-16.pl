% 28-16.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 28. Sequences, Motifs, and Correlation: 28.15 Karnaugh Map.
% Program block 16 of the chapter.

% semantic_classes(-Classes): the semantic classes
% in standard order.
semantic_classes(Classes) :-
    setof(C, K^semantic(K, C), Classes).

% present(+TID, +Class, -Bit): 1 if thread TID
% has a message of Class, else 0.
present(TID, Class, Bit) :-
    (   once(( msg(N, _, _, TID, _, _),
               mapped(N, Class) ))
    ->  Bit = 1
    ;   Bit = 0
    ).

% karnaugh_map: print the thread-by-class grid,
% one row per thread, the bits in class order.
karnaugh_map :-
    semantic_classes(Classes),
    forall(trace_thread(TID),
           ( findall(Bit,
                     ( member(C, Classes),
                       present(TID, C, Bit) ),
                     Bits),
             atomic_list_concat(Bits, ' ', Row),
             format("~t~d~5|  ~w~n", [TID, Row])
           )).

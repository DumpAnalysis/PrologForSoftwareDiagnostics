% 09-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 9. Collecting Solutions and Aggregation: 9.6 Diagnostic Use.
% Program block 6 of the chapter.

% stack_trace_collection(Collection): Collection
% is the list of TID-Frames pairs, one per thread.
stack_trace_collection(Collection) :-
    findall(TID-Frames,
            ( thread(TID, _),
              stack_trace(TID, Frames)
            ),
            Collection).

% print_depths(Collection): one line per thread
% with the depth of its stack trace.
print_depths(Collection) :-
    forall(member(TID-Frames, Collection),
           ( length(Frames, Depth),
             format("~d~t~6|~t~d~4+~n",
                    [TID, Depth])
           )).

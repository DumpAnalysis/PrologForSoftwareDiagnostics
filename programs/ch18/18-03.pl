% 18-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 18. Stack Traces and Threads: 18.2 Stack Trace Collection (Unmanaged Space).
% Program block 3 of the chapter.

% stack_trace_collection(Collection): Collection
% is the list of TID-Frames pairs, one per thread.
stack_trace_collection(Collection) :-
    findall(TID-Frames,
            ( thread(TID, _),
              stack_trace(TID, Frames)
            ),
            Collection).

% print_top_frames(Collection): one line per
% thread with the symbol of its top frame.
print_top_frames(Collection) :-
    forall(member(TID-[Top | _], Collection),
           ( frame_symbol(Top, Symbol),
             format("~d ~a~n", [TID, Symbol])
           )).

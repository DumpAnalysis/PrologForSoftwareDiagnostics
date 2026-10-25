% 18-13.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 18. Stack Traces and Threads: 18.13 Stack Trace Set.
% Program block 13 of the chapter.

% stack_trace_set(Signature, TIDs): TIDs are the
% threads whose signature is Signature, at least
% the threshold many.
stack_trace_set(Sig, TIDs) :-
    bagof(TID,
          P^( thread(TID, P),
              stack_trace_signature(TID, Sig)
            ),
          TIDs),
    threshold(set_size, Min),
    length(TIDs, Size),
    Size >= Min.

% stack_trace_set(Depth, Signature, TIDs): as
% stack_trace_set/2 on the top Depth frames.
stack_trace_set(Depth, Sig, TIDs) :-
    bagof(TID,
          P^( thread(TID, P),
              top_signature(TID, Depth, Sig)
            ),
          TIDs),
    threshold(set_size, Min),
    length(TIDs, Size),
    Size >= Min.

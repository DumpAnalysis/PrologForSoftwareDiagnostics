% 18-15.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 18. Stack Traces and Threads: 18.15 Caller-n-Callee.
% Program block 15 of the chapter.

% caller_n_callee(Caller, Callee, TID): in the
% stack trace of TID the frame with key Callee is
% directly above the frame with key Caller.
caller_n_callee(Caller, Callee, TID) :-
    thread(TID, _),
    stack_trace_signature(TID, Signature),
    nextto(Callee, Caller, Signature).

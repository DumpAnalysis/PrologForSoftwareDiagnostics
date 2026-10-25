% 18-04.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 18. Stack Traces and Threads: 18.3 Stack Trace Collection (Predicate).
% Program block 4 of the chapter.

% stack_trace_collection(Pred, Collection): the
% stack traces of the threads whose frame list
% satisfies the closure Pred.
stack_trace_collection(Pred, Collection) :-
    stack_trace_collection(All),
    include([_-Frames]>>call(Pred, Frames), All,
            Collection).

% has_module(Module, Frames): some frame of the
% list Frames is in Module.
has_module(Module, Frames) :-
    memberchk(frame(_, _, Module, _, _), Frames).

% has_function(F, Frames): some frame of the list
% Frames names the function F.
has_function(F, Frames) :-
    memberchk(frame(_, _, _, F, _), Frames).

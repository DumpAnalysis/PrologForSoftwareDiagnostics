% 18-17.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 18. Stack Traces and Threads: 18.17 Incorrect Stack Trace.
% Program block 17 of the chapter.

% incorrect_stack_trace(TID, Reason): the stack
% trace of TID may be incorrect for Reason, a
% module on it without full symbols.
incorrect_stack_trace(TID, no_symbols(M)) :-
    thread(TID, _),
    distinct(M, frame(TID, _, M, _, _)),
    module_info(M, symbols, none).
incorrect_stack_trace(TID, export_symbols(M)) :-
    thread(TID, _),
    distinct(M, frame(TID, _, M, _, _)),
    module_info(M, symbols, export).

% 18-21.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 18. Stack Traces and Threads: 18.21 Execution Residue (User Space).
% Program block 21 of the chapter.

% execution_residue(TID, Addr, Module, Offset):
% the raw stack word at Addr of TID holds a code
% address of Module that is not page-aligned.
execution_residue(TID, Addr, Module, Offset) :-
    raw_stack(TID, Addr, Value),
    symbol_like(Value, Module, Offset),
    Offset /\ 0xfff =\= 0.

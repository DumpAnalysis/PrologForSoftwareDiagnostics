% 18-16.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 18. Stack Traces and Threads: 18.16 Procedure Call Chain.
% Program block 16 of the chapter.

% procedure_call_chain(TID, Chain): Chain is the
% list of functions of TID from the bottom frame
% to the top, in the order the calls were made.
procedure_call_chain(TID, Chain) :-
    reversed_signature(TID, Reversed),
    pairs_values(Reversed, Chain).

% chain_contains(TID, Sub): Sub is a contiguous
% part of the call chain of TID.
chain_contains(TID, Sub) :-
    procedure_call_chain(TID, Chain),
    append(_, Rest, Chain),
    append(Sub, _, Rest).

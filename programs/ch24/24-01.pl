% 24-01.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 24. Trace Structure.
% Program block 1 of the chapter.

:- [trace1].
:- use_module(library(dcg/basics)).

% truncated(Text, Width, Short): Short is Text cut
% to at most Width characters.
truncated(Text, Width, Short) :-
    string_length(Text, Len),
    (   Len =< Width
    ->  Short = Text
    ;   sub_string(Text, 0, Width, _, Short)
    ).

% print_row(N): print message N on one line.
print_row(N) :-
    msg(N, Time, _, TID, Component, Text),
    truncated(Text, 23, Short),
    format("~t~d~2| ~t~3f~9| ~d ~a~t~26| ~s~n",
           [N, Time, TID, Component, Short]).

% print_messages(Ns): print the messages whose
% numbers are in Ns, one per line.
print_messages(Ns) :-
    forall(member(N, Ns), print_row(N)).

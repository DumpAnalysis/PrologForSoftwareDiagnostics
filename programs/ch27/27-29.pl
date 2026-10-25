% 27-29.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.27 Message Annotations.
% Program block 29 of the chapter.

:- dynamic message_annotation/2.

% annotate(+N, +Note): attach Note to message N.
annotate(N, Note) :-
    assertz(message_annotation(N, Note)).

% print_annotated(+Ns): print each message with
% its annotations indented below it.
print_annotated(Ns) :-
    forall(member(N, Ns),
           ( print_msg(N),
             forall(message_annotation(N, Note),
                    format("~t~8|> ~s~n", [Note]))
           )).

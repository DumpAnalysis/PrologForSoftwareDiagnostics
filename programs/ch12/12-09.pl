% 12-09.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 12. Definite Clause Grammars: 12.7 Grammars over Files.
% Program block 9 of the chapter.

% log_lines(N, Msgs): the msg/6 terms of the lines
% from here to the end of input, numbered from N.
log_lines(N, Msgs) -->
    (   eos
    ->  { Msgs = [] }
    ;   log_line(N, Msg), "\n",
        { Msgs = [Msg | Msgs1],
          N1 is N + 1
        },
        log_lines(N1, Msgs1)
    ).

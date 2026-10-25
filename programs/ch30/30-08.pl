% 30-08.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 30. Scale and Performance: 30.9 Streaming from Files.
% Program block 8 of the chapter.

:- use_module(library(dcg/basics)).
:- use_module(library(pure_input)).

% write_log(+File): the synthetic trace as text.
write_log(File) :-
    setup_call_cleanup(
        open(File, write, S),
        forall(smsg(N, T, P, TID, C, Text),
               format(S,
                      "~d ~3f [~d:~d] ~a: ~s~n",
                      [N, T, P, TID, C, Text])),
        close(S)).

% log_line(-N, -Time)//: one line; the rest of the
% line is skipped.
log_line(N, Time) -->
    integer(N), " ", number(Time), " ",
    string_without("\n", _), "\n".

% gaps(+Prev, +C0, -C)//: count the gaps of more
% than a second between consecutive lines.
gaps(Prev, C0, C) -->
    log_line(_, T),
    { (   Prev = time(T0), T - T0 > 1.0
      ->  C1 is C0 + 1
      ;   C1 = C0
      ) },
    gaps(time(T), C1, C).
gaps(_, C, C) -->
    eos.

count_gaps(File, Count) :-
    once(phrase_from_file(gaps(none, 0, Count),
                          File)).

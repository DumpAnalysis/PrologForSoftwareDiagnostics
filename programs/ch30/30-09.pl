% 30-09.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 30. Scale and Performance: 30.9 Streaming from Files.
% Program block 9 of the chapter.

% count_lines(+File, -N): lines of File.
count_lines(File, N) :-
    setup_call_cleanup(
        open(File, read, S),
        count_lines(S, 0, N),
        close(S)).

count_lines(S, N0, N) :-
    read_line_to_string(S, Line),
    (   Line == end_of_file
    ->  N = N0
    ;   N1 is N0 + 1,
        count_lines(S, N1, N)
    ).

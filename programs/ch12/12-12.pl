% 12-12.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 12. Definite Clause Grammars: 12.8 Diagnostic Use.
% Program block 12 of the chapter.

% thread_header(TID): the line that introduces a
% thread in ~*k output; TID is read from Id:.
thread_header(TID) -->
    [_], blanks, integer(_), blanks,
    "Id: ", xinteger(_), ".", xinteger(TID),
    string_without("\n", _), "\n".

% column_header: the # Child-SP ... line.
column_header -->
    blanks, "#", string_without("\n", _), "\n".

% frame_lines(TID, Frames): the frame lines that
% follow, each a frame/5 term of thread TID.
frame_lines(TID, Frames) -->
    (   frame_line(TID, F), "\n"
    ->  { Frames = [F | Fs] },
        frame_lines(TID, Fs)
    ;   { Frames = [] }
    ).

% thread_block(Frames): one thread's header and
% frames.
thread_block(Frames) -->
    thread_header(TID),
    column_header,
    frame_lines(TID, Frames).

% k_output(Frames): the frames of every thread in
% the output, in order.
k_output(Frames) -->
    (   eos
    ->  { Frames = [] }
    ;   thread_block(Fs),
        k_output(Rest),
        { append(Fs, Rest, Frames) }
    ).

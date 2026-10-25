% 27-21.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.19 Exception Stack Trace.
% Program block 21 of the chapter.

:- use_module(library(dcg/basics)).

% frame_line(-Frame)//: parse a stack frame line
% into frame(N, Module, Function, Offset).
frame_line(frame(N, Module, Function, Offset)) -->
    blanks, integer(N), blank, blanks,
    string_without("!", MCodes), "!",
    string_without("+", FCodes), "+0x",
    xinteger(Offset), eos,
    { atom_codes(Module, MCodes),
      atom_codes(Function, FCodes) }.

% frame_message(?N, -Frame): message N is a frame
% line.
frame_message(N, Frame) :-
    text_of(N, Text),
    string_codes(Text, Codes),
    phrase(frame_line(Frame), Codes).

% exception_stack_trace(?TID, -Ns, -Frames): the
% frame messages Ns of thread TID parse to Frames.
exception_stack_trace(TID, Ns, Frames) :-
    trace_thread(TID),
    findall(N,
            ( msg(N, _, _, TID, _, _),
              frame_message(N, _)
            ),
            Ns),
    Ns = [_|_],
    maplist(frame_message, Ns, Frames).

% print_frames(+Frames): one line per frame, as a
% debugger would print it.
print_frames(Frames) :-
    forall(member(frame(N, M, F, O), Frames),
           format("~t~d~2| ~a!~a+0x~16r~n",
                  [N, M, F, O])).

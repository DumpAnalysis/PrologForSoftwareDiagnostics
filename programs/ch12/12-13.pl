% 12-13.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 12. Definite Clause Grammars: 12.8 Diagnostic Use.
% Program block 13 of the chapter.

% sample_k_line(Line): a line of the abridged ~*k
% output.
sample_k_line(
    ".  0  Id: 1018.64 Suspend: 1 \c
     Teb: 00000000`0025d000 Unfrozen").
sample_k_line(
    " # Child-SP          RetAddr           \c
     Call Site").
sample_k_line(
    "00 00000000`0014f5a8 00007ffb`b0b2a0b0 \c
     kernelbase!SleepEx+0x9e").
sample_k_line(
    "01 00000000`0014f5b0 00007ff6`1d10a3a0 \c
     appserver!MainLoop+0x1b2").
sample_k_line(
    "   1  Id: 1018.65 Suspend: 1 \c
     Teb: 00000000`00260000 Unfrozen").
sample_k_line(
    " # Child-SP          RetAddr           \c
     Call Site").
sample_k_line(
    "00 00000000`0024f8c8 00007ffb`b0b2a0b0 \c
     kernelbase!SleepEx+0x9e").
sample_k_line(
    "01 00000000`0024f8d0 00007ffb`7a002a10 \c
     cachelib+0x2a10").

% write_sample_k(File): write the sample output.
write_sample_k(File) :-
    setup_call_cleanup(
        open(File, write, Out),
        forall(sample_k_line(Line),
               format(Out, "~s~n", [Line])),
        close(Out)).

% frame(TID, N, Module, Function, Offset): the
% schema relation, filled from parsed k output.
:- dynamic frame/5.

% load_k(File): parse the ~*k output in File and
% assert its frames.
load_k(File) :-
    phrase_from_file(k_output(Frames), File),
    maplist(assertz, Frames).

% print_frames(TID): the stack trace of TID as
% numbered lines, from the parsed frames.
print_frames(TID) :-
    forall(frame(TID, N, M, F, O),
           ( Frame = frame(TID, N, M, F, O),
             phrase(frame_text(Frame), Codes),
             format("~s~n", [Codes])
           )).

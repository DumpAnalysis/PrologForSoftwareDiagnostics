% 15-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 15. Memory Dumps as Knowledge Bases: 15.3 From Debugger Output to Facts.
% Program block 5 of the chapter.

% parse_record(Log, TID, LineNo-Text, Frame):
% Frame is the frame/5 term for the frame line
% Text of TID; a line the grammar rejects raises a
% syntax error located at Log:LineNo.
parse_record(Log, TID, LineNo-Text, Frame) :-
    (   parse_k_line(TID, Text, Frame0)
    ->  Frame = Frame0
    ;   format(atom(Where), "~w:~d: ~w",
               [Log, LineNo, Text]),
        throw(error(syntax_error(k_line),
                    context(parse_record/4,
                            Where)))
    ).

% check_keys(Frames): the (TID, N) keys of Frames
% are distinct; a repeated key raises an error.
check_keys(Frames) :-
    findall(T-N,
            member(frame(T, N, _, _, _), Frames),
            Keys),
    msort(Keys, Sorted),
    (   append(_, [Key, Key | _], Sorted)
    ->  domain_error(unique_frame_key, Key)
    ;   true
    ).

% write_frames(Log, TID, File): parse every frame
% line of TID in Log and write the frame/5 facts
% to File, one per line. Nothing is written until
% every line has parsed and the keys are distinct.
write_frames(Log, TID, File) :-
    findall(LineNo-Text,
            log_line(Log, LineNo, Text),
            Records),
    maplist(parse_record(Log, TID),
            Records, Frames),
    check_keys(Frames),
    setup_call_cleanup(
        open(File, write, S),
        maplist(portray_clause(S), Frames),
        close(S)).

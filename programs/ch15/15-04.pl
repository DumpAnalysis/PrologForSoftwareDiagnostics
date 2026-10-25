% 15-04.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 15. Memory Dumps as Knowledge Bases: 15.3 From Debugger Output to Facts.
% Program block 4 of the chapter.

% k_columns(LineNo, N, ChildSP, RetAddr,
% CallSite): the columns of log line LineNo of
% dump1.log, a frame line of thread 108.
k_columns(212, '00', '0000004a`2b3ff8c8',
          '00007ffb`b0b2a09e',
          'ntdll!NtDelayExecution+0x14').
k_columns(213, '01', '0000004a`2b3ff8d0',
          '00007ff6`1d10503a',
          'KERNELBASE!SleepEx+0x9e').
k_columns(214, '02', '0000004a`2b3ff970',
          '00007ffb`b1c14014',
          'appserver!Housekeeping::Run+0x3a').
k_columns(215, '03', '0000004a`2b3ff9b0',
          '00007ffb`b2a52651',
          'KERNEL32!BaseThreadInitThunk+0x14').
k_columns(216, '04', '0000004a`2b3ff9e0',
          '00000000`00000000',
          'ntdll!RtlUserThreadStart+0x21').

% log_line(Log, LineNo, Text): line LineNo of the
% log file Log is Text. dump1.log holds the frame
% lines of thread 108 as the debugger printed
% them; bad.log holds the same lines with the
% offset of line 214 removed, a form the grammar
% does not accept, for the check at the end of
% this section.
log_line('dump1.log', LineNo, Text) :-
    k_columns(LineNo, N, SP, Ret, Sym),
    atomic_list_concat([N, SP, Ret, Sym], ' ',
                       Text).
log_line('bad.log', LineNo, Text) :-
    log_line('dump1.log', LineNo, Text0),
    (   LineNo =:= 214
    ->  atom_concat(Text, '+0x3a', Text0)
    ;   Text = Text0
    ).

% parse_k_line(TID, Text, Frame): Frame is the
% frame/5 term for the frame line Text of TID.
parse_k_line(TID, Text, Frame) :-
    atom_codes(Text, Codes),
    phrase(k_line(TID, Frame), Codes).

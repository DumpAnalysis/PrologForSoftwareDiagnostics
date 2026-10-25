% 23-02.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 23. Dump Quality, Composition, and Reports: 23.1 Manual Dump (Process).
% Program block 2 of the chapter.

% break_in_frame(TID): a frame left by a debugger
% break-in on the stack trace of TID.
break_in_frame(TID) :-
    frame(TID, _, _, Function, _),
    memberchk(Function, [ 'DbgBreakPoint',
                          'DbgUiRemoteBreakin' ]).

% manual_dump(Sign): the dump was written on
% request: no thread has an exception record, or a
% debugger broke in.
manual_dump(no_exception_record) :-
    \+ exception_record(_, _, _).
manual_dump(break_in(TID)) :-
    break_in_frame(TID).

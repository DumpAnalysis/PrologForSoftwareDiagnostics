% 23-08.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 23. Dump Quality, Composition, and Reports: 23.7 No Current Thread.
% Program block 8 of the chapter.

% no_current_thread: the debugger reported no
% current thread when it opened the dump.
no_current_thread :-
    dump_info(current_thread, none).

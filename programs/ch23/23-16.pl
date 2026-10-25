% 23-16.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 23. Dump Quality, Composition, and Reports: 23.10.3 The Evidence Contract from an Importing Module.
% Program block 16 of the chapter.

% has_type(captured_thread, T): a type that a
% loaded file could add to library(error), whose
% clause reads the dump. must_be/2 dispatches
% through this multifile hook.
:- multifile error:has_type/2.

error:has_type(captured_thread, T) :-
    user:thread_time(T, 8450, 1230).

% numlist(Low, High, List) in user: a meta-call
% from the module would reach it before the
% library's.
numlist(_, _, from_user).

% 07-07.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 7. Control: 7.3 If-Then-Else.
% Program block 7 of the chapter.

% cpu_class(Ms, Class): the class of a thread by
% its CPU time in milliseconds.
cpu_class(Ms, Class) :-
    (   Ms >= 1000
    ->  Class = heavy
    ;   Ms > 0
    ->  Class = light
    ;   Class = idle
    ).

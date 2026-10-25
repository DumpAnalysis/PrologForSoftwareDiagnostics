% 07-18.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 7. Control: 7.7 Diagnostic Use.
% Program block 18 of the chapter.

% print_thread_classes: one line per thread with
% its class and CPU time.
print_thread_classes :-
    forall(thread_class(TID, Class),
           ( thread_time(TID, U, K),
             Ms is U + K,
             format("~d~t~6|~a~t~16|~t~d~6+ ms~n",
                    [TID, Class, Ms])
           )).

% 06-07.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 6. Arithmetic: 6.7 Diagnostic Use.
% Program block 7 of the chapter.

% print_cpu_share(TID): one table row for TID.
print_cpu_share(TID) :-
    cpu_time(TID, Ms),
    cpu_share(TID, Percent),
    format("~d~t~6|~t~D~8+ ms~3+~t~1f~8+%~n",
           [TID, Ms, Percent]).

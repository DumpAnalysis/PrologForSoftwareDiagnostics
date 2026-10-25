% report.2.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 1. Logic Programming and Diagnostics: 1.6 Errors and Warnings at Load Time.
% Program block 3 of the chapter; loaded fresh.
% The book stores this block as report.pl (version 2 of 2 in the chapter; each later version replaces the file).

:- [locks].

% blocked_report(TID): print who blocks TID.
blocked_report(TID) :-
    blocked_by(TID, Owner),
    write(TID),
    write(' is blocked by '),
    write(Owner),
    nl.

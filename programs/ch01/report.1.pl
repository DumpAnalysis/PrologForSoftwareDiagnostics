% report.1.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 1. Logic Programming and Diagnostics: 1.6 Errors and Warnings at Load Time.
% Program block 2 of the chapter.
% The book stores this block as report.pl (version 1 of 2 in the chapter; each later version replaces the file).

:- [locks].

% blocked_report(TID): print who blocks TID.
blocked_report(TID) :-
    blocked_by(TID, Owner),
    write(TID),
    write(' is blocked by '),
    write(Ownr),
    nl.

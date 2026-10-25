% 07-15.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 7. Control: 7.7 Diagnostic Use.
% Program block 15 of the chapter.

% thread_last_error(TID, Code): Code is the last
% error code recorded for TID, or unrecorded.
thread_last_error(TID, Code) :-
    must_be(integer, TID),
    (   last_error(TID, Code0)
    ->  Code = Code0
    ;   Code = unrecorded
    ).

% module_company(Module, Company): Company is the
% vendor recorded for Module, or unrecorded.
module_company(Module, Company) :-
    must_be(atom, Module),
    (   module_info(Module, company, Company0)
    ->  Company = Company0
    ;   Company = unrecorded
    ).

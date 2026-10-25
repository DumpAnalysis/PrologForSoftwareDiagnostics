% 03-01.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 3. Unification: 3.7 Diagnostic Use.
% Program block 1 of the chapter.

:- [dump1].

% template(Name, Frame): the frame template
% called Name.
template(top_in_ntdll,
         frame(_, 0, ntdll, _, _)).
template(cs_wait,
         frame(_, _, ntdll,
               'RtlEnterCriticalSection', _)).
template(unresolved,
         frame(_, _, _, 'Unknown', _)).

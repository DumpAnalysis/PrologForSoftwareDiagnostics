% 02-01.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 2. Terms: 2.3 Variables.
% Program block 1 of the chapter.

% module_of(Frame, Module): Module is the module
% argument of the frame term Frame.
module_of(frame(_TID, _N, Module, _F, _Off),
          Module).

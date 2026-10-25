% 07-01.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 7. Control: 7.1 Determinism and Choice Points.
% Program block 1 of the chapter.

% severity_class(Bits, Class): the class of a
% status code whose two top bits are Bits.
severity_class(0, success).
severity_class(1, informational).
severity_class(2, warning).
severity_class(3, error).

% code_class(Code, Class): Class is the severity
% class of the 32-bit status code Code.
code_class(Code, Class) :-
    Bits is Code >> 30,
    severity_class(Bits, Class).

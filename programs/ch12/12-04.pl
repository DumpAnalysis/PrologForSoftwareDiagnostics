% 12-04.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 12. Definite Clause Grammars: 12.2 The Translation.
% Program block 4 of the chapter.

% at_digit: the next code is a digit, which is not
% consumed.
at_digit, [C] --> [C], { code_type(C, digit) }.

% 12-14.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 12. Definite Clause Grammars: 12.8 Diagnostic Use.
% Program block 14 of the chapter.

% error_prefix: the text begins with "Error:".
error_prefix --> "Error:".

% error_message(N): message N is an Error Message:
% its text begins with the error prefix.
error_message(N) :-
    msg(N, _, _, _, _, Text),
    string_codes(Text, Codes),
    phrase(error_prefix, Codes, _).

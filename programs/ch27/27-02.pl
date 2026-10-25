% 27-02.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.1 Error Message.
% Program block 2 of the chapter.

% error_message(?N): message N is marked as an
% error by the component that wrote it.
error_message(N) :-
    text_of(N, Text),
    sub_string(Text, 0, _, _, "Error:").

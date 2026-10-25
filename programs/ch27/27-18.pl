% 27-18.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.17 Hidden Error.
% Program block 18 of the chapter.

% failure_word(?Word): Word reports a failure
% without the error marking.
failure_word("failed").
failure_word("exception").
failure_word("No idle").
failure_word("Unhandled").

% hidden_error(?N): message N is not marked as an
% error but reports one.
hidden_error(N) :-
    text_of(N, Text),
    \+ error_message(N),
    once(( failure_word(W),
           sub_string(Text, _, _, _, W) )).

% 27-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.2 Significant Event.
% Program block 3 of the chapter.

% significant_event(?N, ?Why): message N is
% significant for the reason Why.
significant_event(N, first_error) :-
    aggregate_all(min(E), error_message(E), N).
significant_event(N, exception) :-
    text_of(N, Text),
    sub_string(Text, _, _, _, "exception").
significant_event(N, lifecycle) :-
    text_of(N, Text),
    sub_string(Text, 0, _, _, "Service").
significant_event(N, saturation) :-
    text_of(N, Text),
    sub_string(Text, 0, _, _, "No idle worker").

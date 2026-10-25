% 24-15.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 24. Trace Structure: 24.13 Truncated Trace.
% Program block 15 of the chapter.

% start_marker(Prefix), end_marker(Prefix): the
% text a complete trace begins and ends with.
start_marker("Service starting").
end_marker("Service stopping").

% marked(N, Marker): the text of message N begins
% with the prefix given by the fact Marker/1.
marked(N, Marker) :-
    msg(N, _, _, _, _, Text),
    call(Marker, Prefix),
    sub_string(Text, 0, _, _, Prefix).

% truncated_trace(Set, Where): the message set
% Set, read as a trace, is cut at Where (start or
% end).
truncated_trace(Set, start) :-
    head_message(Set, N),
    \+ marked(N, start_marker).
truncated_trace(Set, end) :-
    tail_message(Set, N),
    \+ marked(N, end_marker).

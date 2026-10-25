% 26-14.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 26. Activities and Threads of Activity: 26.12 Background and Foreground Components.
% Program block 14 of the chapter.

% foreground_components(From, To, Cs): the
% components with messages in From..To that are
% not background components.
foreground_components(From, To, Cs) :-
    window_messages(From, To, Set),
    aggregate_all(set(C),
                  ( member(N, Set),
                    msg(N, _, _, _, C, _) ),
                  Present),
    background_components(Background),
    ord_subtract(Present, Background, Cs).

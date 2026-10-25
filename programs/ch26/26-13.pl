% 26-13.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 26. Activities and Threads of Activity: 26.12 Background and Foreground Components.
% Program block 13 of the chapter.

% window(From): From is the start of a one-second
% window of the trace.
window(From) :-
    aggregate_all(max(T), msg(_, T, _, _, _, _),
                  End),
    Last is floor(End),
    between(0, Last, From).

% active_window(From): the window has a message.
active_window(From) :-
    window(From),
    To is From + 1,
    msg(_, T, _, _, _, _),
    T >= From, T < To.

% in_window(C, From): the window has a message of
% component C.
in_window(C, From) :-
    window(From),
    To is From + 1,
    msg(_, T, _, _, C, _),
    T >= From, T < To.

% presence(C, Share): C has messages in the share
% Share of the active windows.
presence(C, Share) :-
    aggregate_all(set(C0), msg(_, _, _, _, C0, _),
                  Cs),
    member(C, Cs),
    aggregate_all(count,
                  distinct(F, in_window(C, F)),
                  Own),
    aggregate_all(count,
                  distinct(F, active_window(F)),
                  All),
    Share is Own / All.

print_presence :-
    forall(presence(C, Share),
           format("~a~t~14|~2f~n", [C, Share])).

% background_components(Cs): the components whose
% presence reaches the background threshold.
background_components(Cs) :-
    threshold(background, Min),
    findall(C,
            ( presence(C, Share), Share >= Min ),
            Cs).

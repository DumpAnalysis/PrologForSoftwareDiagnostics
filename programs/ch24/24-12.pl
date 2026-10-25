% 24-12.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 24. Trace Structure: 24.10 Focus of Tracing.
% Program block 12 of the chapter.

% focus(Focus): the current focus of analysis:
% thread(TID), component(C) or interval(From, To).
focus(thread(102)).

% in_focus(N): message N is within the focus.
in_focus(N) :-
    focus(Focus),
    focus_member(Focus, N).

focus_member(thread(TID), N) :-
    msg(N, _, _, TID, _, _).
focus_member(component(C), N) :-
    msg(N, _, _, _, C, _).
focus_member(interval(From, To), N) :-
    msg(N, T, _, _, _, _),
    From =< T, T =< To.

% focus_of_tracing(Set): Set is the message set
% within the focus.
focus_of_tracing(Set) :-
    findall(N, in_focus(N), Ns),
    sort(Ns, Set).

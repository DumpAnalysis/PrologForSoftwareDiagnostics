% 14-15.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 14. Constraints and Coroutining: 14.7 Diagnostic Use.
% Program block 15 of the chapter.

% print_merged(S, From, To): print both logs
% merged under skew S, for application times
% From..To.
print_merged(S, From, To) :-
    findall(T-app(Text),
            ( app_msg(N, T),
              msg(N, _, _, _, _, Text) ),
            As),
    findall(T-db(Text),
            ( dblog(Tdb, _, Text),
              T is Tdb - S ),
            Ds),
    append(As, Ds, All),
    keysort(All, Sorted),
    forall(( member(T-Event, Sorted),
             T >= From, T =< To ),
           print_event(T, Event)).

print_event(T, app(Text)) :-
    format("~w app ~w~n", [T, Text]).
print_event(T, db(Text)) :-
    format("~w db  ~w~n", [T, Text]).

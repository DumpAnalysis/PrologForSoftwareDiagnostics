% 25-10.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 25. Time: 25.7 Trace Acceleration.
% Program block 10 of the chapter.

% trace_acceleration(Width, From, Acceleration):
% the current of the window after the one starting
% at From minus the current of that window.
trace_acceleration(Width, From, Acceleration) :-
    window(Width, From, To),
    statement_current(From, To, C1),
    Next is To + Width,
    statement_current(To, Next, C2),
    Acceleration is C2 - C1.

% print_acceleration(Width): one signed value per
% window boundary.
print_acceleration(Width) :-
    forall(trace_acceleration(Width, From, A),
           ( (   A >= 0
             ->  Sign = '+'
             ;   Sign = ''
             ),
             format("~t~d~3| ~t~a~w~10|~n",
                    [From, Sign, A]) )).

% 25-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 25. Time: 25.4 Statement Density and Current.
% Program block 6 of the chapter.

% window_messages(+From, +To, -Set): Set is the
% set of messages with From =< Time < To; From and
% To are times in seconds, From < To.
window_messages(From, To, Set) :-
    findall(N,
            ( msg(N, T, _, _, _, _),
              T >= From, T < To ),
            Ns),
    sort(Ns, Set).

% statement_current(+From, +To, -Current): Current
% is the number of messages per second in the
% window From..To, in seconds, From < To.
statement_current(From, To, Current) :-
    window_messages(From, To, Set),
    length(Set, Count),
    Current is Count / (To - From).

% window(+Width, -From, -To): the consecutive
% windows of Width seconds covering the trace.
% Width is a positive integer number of seconds;
% From and To are then integers in seconds.
window(Width, From, To) :-
    must_be(positive_integer, Width),
    trace_end(End),
    Last is End // (Width * 1000),
    between(0, Last, I),
    From is I * Width,
    To is From + Width.

% print_current(Width): the current per window, as
% a number and as a bar.
print_current(Width) :-
    forall(window(Width, From, To),
           print_window_current(From, To)).

print_window_current(From, To) :-
    statement_current(From, To, Current),
    Stars is round(Current),
    format("~t~d~3|-~d~t~7| ~t~1f~12| ~*c~n",
           [From, To, Current, Stars, 0'*]).

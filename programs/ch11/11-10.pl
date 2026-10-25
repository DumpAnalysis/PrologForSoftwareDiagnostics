% 11-10.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 11. The Dynamic Database, Global State, and Tabling: 11.7 Diagnostic Use.
% Program block 10 of the chapter.

% print_chain(Chain): one line per step of the
% chain, with the critical section waited for.
print_chain(Chain) :-
    forall(nextto(Waiter, Owner, Chain),
           print_step(Waiter, Owner)).

% print_step(Waiter, Owner): one line of a chain.
print_step(Waiter, Owner) :-
    waits_for(Waiter, critical_section, Addr),
    format("~d waits for ~16r, owner ~d~n",
           [Waiter, Addr, Owner]).

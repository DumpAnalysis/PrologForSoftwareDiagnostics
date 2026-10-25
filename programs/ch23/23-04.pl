% 23-04.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 23. Dump Quality, Composition, and Reports: 23.3 Inconsistent Dump.
% Program block 4 of the chapter.

% inconsistency(Finding): one disagreement between
% two kinds of fact in the dump.
inconsistency(owner_not_a_thread(Addr, Owner)) :-
    critical_section(Addr, Owner, _, _),
    Owner =\= 0,
    \+ thread(Owner, _).
inconsistency(wait_on_unknown_section(TID)) :-
    waits_for(TID, critical_section, Addr),
    \+ critical_section(Addr, _, _, _).
inconsistency(wait_on_free_section(TID)) :-
    waits_for(TID, critical_section, Addr),
    critical_section(Addr, 0, _, _).
inconsistency(state_without_record(TID)) :-
    thread_state(TID, waiting(exception)),
    \+ exception_record(TID, _, _).
inconsistency(record_without_state(TID)) :-
    exception_record(TID, _, _),
    \+ thread_state(TID, waiting(exception)).
inconsistency(fault_outside_top_module(TID)) :-
    exception_record(TID, _, Addr),
    frame(TID, 0, Module, _, _),
    \+ ( module(Module, Base, Size),
         Base =< Addr,
         Addr < Base + Size
       ).

% inconsistent_dump(Findings): the dump disagrees
% with itself in at least one way.
inconsistent_dump(Findings) :-
    findall(F, inconsistency(F), Findings),
    Findings \== [].

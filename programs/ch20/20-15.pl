% 20-15.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 20. Synchronization Patterns: 20.13 Blocking Module.
% Program block 15 of the chapter.

% blocking_module(?Addr, -Owner, -Module): Owner
% holds the critical section at Addr and is
% executing in Module, its topmost frame outside
% the system modules.
blocking_module(Addr, Owner, Module) :-
    critical_section(Addr, Owner, _, _),
    Owner =\= 0,
    aggregate_all(min(N),
                  ( frame(Owner, N, M, _, _),
                    \+ system_module(M)
                  ),
                  Top),
    frame(Owner, Top, Module, _, _).

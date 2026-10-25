% 19-04.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 19. Exceptions and Faults: 19.2 Fault Context.
% Program block 4 of the chapter.

% fault_context(TID, Context): Context collects
% the exception record of TID, the module of its
% address, its parameters and the thread's last
% error.
fault_context(TID, Context) :-
    exception_record(TID, Code, Addr),
    (   status_name(Code, Name)
    ->  true
    ;   Name = unknown
    ),
    (   address_module(Addr, M)
    ->  true
    ;   M = none
    ),
    findall(K-V, exception_info(TID, K, V), Info),
    (   last_error(TID, E)
    ->  true
    ;   E = unrecorded
    ),
    Context = context(status(Code, Name),
                      address(Addr, M),
                      Info, last_error(E)).

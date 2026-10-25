% 17-08.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 17. The Pattern as a Predicate: 17.6 The Catalog as Data.
% Program block 8 of the chapter.

% pattern(Name, Kind, Chapter): the pattern Name
% occurs in artifacts of Kind; Chapter treats it.
pattern('Spiking Thread', memory_dump, 18).
pattern('Blocked Thread (Software)', memory_dump,
        18).
pattern('Frame Regularity', memory_dump, 18).
pattern('NULL Pointer (Data)', memory_dump, 19).
pattern('Wait Chain (Critical Sections)',
        memory_dump, 20).
pattern('Deadlock (Critical Sections)',
        memory_dump, 20).
pattern('Handle Leak', memory_dump, 21).
pattern('No Component Symbols', memory_dump, 22).
pattern('Hooked Functions (User Space)',
        memory_dump, 22).
pattern('Time Delta', software_trace, 25).
pattern('Discontinuity', software_trace, 25).

% recognizer(Name, Pred): Pred/2 is the explainer
% for the pattern Name.
recognizer('Spiking Thread', spiking_thread).
recognizer('Blocked Thread (Software)',
           blocked_thread).
recognizer('Frame Regularity', frame_regularity).
recognizer('NULL Pointer (Data)',
           null_pointer_data).
recognizer('Wait Chain (Critical Sections)',
           wait_chain).
recognizer('Deadlock (Critical Sections)',
           deadlock).
recognizer('Handle Leak', handle_leak).
recognizer('No Component Symbols',
           no_component_symbols).
recognizer('Hooked Functions (User Space)',
           hooked_functions).

% no_component_symbols(Module, E): Module has no
% symbol information.
no_component_symbols(M, E) :-
    module_info(M, symbols, none),
    E = evidence('No Component Symbols', M,
        [ module_info(M, symbols, none) ]).

no_component_symbols(M) :-
    no_component_symbols(M, _).

% hooked_functions(Function, E): the entry of
% Function in some module transfers control into
% another module.
hooked_functions(F, E) :-
    hooked(F, Module, Hooker),
    E = evidence('Hooked Functions (User Space)',
                 F, [hooked(F, Module, Hooker)]).

hooked_functions(F) :-
    hooked_functions(F, _).

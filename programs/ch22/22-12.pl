% 22-12.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 22. Modules, Versions, and Environment: 22.11 Deviant Module.
% Program block 12 of the chapter.

% deviant_module(Module, Key): among at least
% three modules of one vendor, Module alone has
% its value of Key.
deviant_module(Module, Key) :-
    vendor(Module, Vendor),
    aggregate_all(count, vendor(_, Vendor), N),
    N >= 3,
    module_info(Module, Key, Value),
    forall(( vendor(Other, Vendor),
             Other \== Module
           ),
           ( module_info(Other, Key, OtherValue),
             OtherValue \== Value
           )).

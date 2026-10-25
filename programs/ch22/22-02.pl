% 22-02.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 22. Modules, Versions, and Environment: 22.1 Module Variety.
% Program block 2 of the chapter.

% module_variety(Count): the number of modules
% loaded in the process.
module_variety(Count) :-
    aggregate_all(count, module(_, _, _), Count).

% third_party_ratio(Ratio): the share of loaded
% modules that are not system modules.
third_party_ratio(Ratio) :-
    module_variety(Total),
    aggregate_all(count,
                  ( module(M, _, _),
                    \+ system_module(M)
                  ),
                  Others),
    Ratio is Others / Total.

% vendor_variety(Vendors): the set of vendors of
% the loaded modules.
vendor_variety(Vendors) :-
    aggregate_all(set(V), vendor(_, V), Vendors).

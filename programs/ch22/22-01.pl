% 22-01.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 22. Modules, Versions, and Environment.
% Program block 1 of the chapter.

:- [dump1].

% pattern(Name, Artifact, Chapter): the catalog
% entries treated in this chapter.
pattern('Module Variety', memory_dump, 22).
pattern('Not My Version', memory_dump, 22).
pattern('Unknown Component', memory_dump, 22).
pattern('No Component Symbols', memory_dump, 22).
pattern('Missing Component (General)',
    memory_dump, 22).
pattern('Hooked Functions (User Space)',
    memory_dump, 22).
pattern('Hooked Modules', memory_dump, 22).
pattern('Hidden Module', memory_dump, 22).
pattern('Changed Environment', memory_dump, 22).
pattern('Virtualized Process (WOW64)',
    memory_dump, 22).
pattern('Deviant Module', memory_dump, 22).
pattern('Same Vendor', memory_dump, 22).
pattern('Top Module', memory_dump, 22).
pattern('Origin Module', memory_dump, 22).
pattern('Module Hint', memory_dump, 22).
pattern('Historical Information',
    memory_dump, 22).
pattern('Last Error Collection', memory_dump, 22).
pattern('Zombie Processes', memory_dump, 22).
pattern('Special Process', memory_dump, 22).
pattern('Frozen Process', memory_dump, 22).
pattern('Busy System', memory_dump, 22).
pattern('Lateral Damage', memory_dump, 22).
pattern('Ubiquitous Component', memory_dump, 22).

% threshold(Name, Value): the analyst's limits.
threshold(ubiquity, 0.7).

% system_module(Module): a module supplied by the
% operating system or the C runtime. An extension
% of the schema: the analyst's knowledge.
system_module(ntdll).
system_module(kernelbase).
system_module(kernel32).
system_module(ucrtbase).
system_module(msvcp140).

% vendor(Module, Vendor): the company recorded for
% Module; system for a system module without one;
% unrecorded otherwise.
vendor(Module, Vendor) :-
    module(Module, _, _),
    (   module_info(Module, company, Company)
    ->  Vendor = Company
    ;   system_module(Module)
    ->  Vendor = system
    ;   Vendor = unrecorded
    ).

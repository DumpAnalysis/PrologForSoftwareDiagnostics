% 22-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 22. Modules, Versions, and Environment: 22.5 Missing Component (General).
% Program block 6 of the chapter.

% expected_module(Module): the modules the product
% deploys. An extension of the schema: knowledge
% about the product, not content of the dump.
expected_module(appserver).
expected_module(reportengine).
expected_module(dbclient).
expected_module(cachelib).
expected_module(authplugin).

% missing_component(Module): an expected module is
% not loaded.
missing_component(Module) :-
    expected_module(Module),
    \+ module(Module, _, _).

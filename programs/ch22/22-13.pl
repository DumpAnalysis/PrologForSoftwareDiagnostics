% 22-13.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 22. Modules, Versions, and Environment: 22.12 Same Vendor.
% Program block 13 of the chapter.

% stack_module(TID, Module): a non-system module
% with a frame on the stack trace of TID.
stack_module(TID, Module) :-
    frame(TID, _, Module, _, _),
    \+ system_module(Module).

% same_vendor(TID, Vendor, Modules): the two or
% more non-system modules on the stack trace of
% TID all come from Vendor.
same_vendor(TID, Vendor, Modules) :-
    thread(TID, _),
    setof(M, stack_module(TID, M), Modules),
    Modules = [_, _ | _],
    maplist(from_vendor(Vendor), Modules).

from_vendor(Vendor, Module) :-
    vendor(Module, Vendor).

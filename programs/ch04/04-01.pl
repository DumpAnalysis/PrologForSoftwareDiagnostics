% 04-01.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 4. Clauses, Queries, and Search: 4.2 Goal Reduction.
% Program block 1 of the chapter.

% top(TID, Function): the top frame of thread
% TID is in Function.
top(102, 'Table::Find').
top(107, 'Node::Visit').
top(109, 'Buffer::Copy').

% in_module(Function, Module): Function belongs
% to Module.
in_module('Table::Find', reportengine).
in_module('Node::Visit', reportengine).
in_module('Buffer::Copy', dbclient).

% runs_in(TID, Module): the top frame of TID is
% in a function of Module.
runs_in(TID, Module) :-
    top(TID, F),
    in_module(F, Module).

% 04-04.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 4. Clauses, Queries, and Search: 4.5 The Order of Clauses and Goals.
% Program block 4 of the chapter.

% calls(Caller, Callee): Caller contains a call to
% Callee.
calls('Report::Build', 'Table::Insert').
calls('Table::Insert', 'Table::Find').
calls('Report::Build', 'Tree::Walk').
calls('Tree::Walk', 'Node::Visit').
calls('Node::Visit', 'Node::Visit').

% reaches(F, G): there is a chain of one or more
% calls from F to G.
reaches(F, G) :-
    calls(F, G).
reaches(F, H) :-
    calls(F, G),
    reaches(G, H).

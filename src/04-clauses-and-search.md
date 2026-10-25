# Chapter 4. Clauses, Queries, and Search

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/04-clauses-and-search.md`.

## 4.1 Horn Clauses

```{.prolog .query}
?- true.
true.

?- true, true.
true.
```

## 4.2 Goal Reduction

```{.prolog .program}
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
```

```text
?- runs_in(T, reportengine).
   clause  runs_in(TID1, Module1) :-
               top(TID1, F1), in_module(F1, Module1).
   unifier TID1 = T, Module1 = reportengine
?- top(T, F1), in_module(F1, reportengine).
   clause  top(102, 'Table::Find').
   unifier T = 102, F1 = 'Table::Find'
?- in_module('Table::Find', reportengine).
   clause  in_module('Table::Find', reportengine).
   unifier (empty)
?-                                  success: T = 102
```

```{.prolog .query}
?- runs_in(T, reportengine).
T = 102 ;
T = 107 ;
false.
```

## 4.3 The Search Tree

```text
?- runs_in(T, reportengine)
    |
    | runs_in/2, clause 1
    |
?- top(T, F), in_module(F, reportengine)
    |                  |                  |
    | top/2 #1         | top/2 #2         | top/2 #3
    | T = 102          | T = 107          | T = 109
    |                  |                  |
?- in_module(       ?- in_module(      ?- in_module(
   'Table::Find',      'Node::Visit',     'Buffer::Copy',
   reportengine)       reportengine)      reportengine)
    |                  |                  |
    | in_module #1     | in_module #2     | no clause
    |                  |                  |
   []  success        []  success        failure
```

```{.prolog .query}
?- in_module(F, dbclient).
F = 'Buffer::Copy'.

?- in_module(F, reportengine).
F = 'Table::Find' ;
F = 'Node::Visit'.

?- top(T, F).
T = 102,
F = 'Table::Find' ;
T = 107,
F = 'Node::Visit' ;
T = 109,
F = 'Buffer::Copy'.
```

## 4.4 Conjunction, Disjunction, True, and Fail

```{.prolog .query}
?- (X = a ; X = b).
X = a ;
X = b.

?- X = 1 ; X = 2 ; X = 3.
X = 1 ;
X = 2 ;
X = 3.

?- (true ; true).
true ;
true.
```

```{.prolog .query}
?- X = 1, X = 2 ; X = 3.
X = 3.

?- X = 1, (X = 2 ; X = 1).
X = 1.
```

```{.prolog .program}
% stopped(TID): the top frame of TID is in the
% report engine or in the database client.
stopped(TID) :-
    (   runs_in(TID, reportengine)
    ;   runs_in(TID, dbclient)
    ).
```

```{.prolog .query}
?- stopped(T).
T = 102 ;
T = 107 ;
T = 109.
```

```{.prolog .query}
?- fail.
false.

?- false.
false.

?- (fail ; true).
true.
```

```{.prolog .query}
?- top(T, _), write(T), nl, fail.
102
107
109
false.
```

## 4.5 The Order of Clauses and Goals

```{.prolog .program}
% runs_in_reordered(TID, Module): as runs_in/2,
% with the module looked up first.
runs_in_reordered(TID, Module) :-
    in_module(F, Module),
    top(TID, F).
```

```{.prolog .query}
?- runs_in_reordered(T, reportengine).
T = 102 ;
T = 107.

?- runs_in_reordered(T, M).
T = 102,
M = reportengine ;
T = 107,
M = reportengine ;
T = 109,
M = dbclient.
```

```{.prolog .program}
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
```

```{.prolog .query}
?- reaches('Table::Insert', G).
G = 'Table::Find' ;
false.

?- calls(F, F).
F = 'Node::Visit'.
```

```{.prolog .query}
?- reaches('Report::Build', G).
G = 'Table::Insert' ;
G = 'Tree::Walk' ;
G = 'Table::Find' ;
G = 'Node::Visit' ;
G = 'Node::Visit' ;
G = 'Node::Visit' ;
...
```

```prolog
% Left recursion: do not write this.
reaches_left(F, H) :-
    reaches_left(F, G),
    calls(G, H).
reaches_left(F, G) :-
    calls(F, G).
```

```text
ERROR: Stack limit (1.0Gb) exceeded
ERROR:   Stack sizes: local: 0.9Gb, global: 48.4Mb, trail: 0Kb
ERROR:   Stack depth: 6,340,556, last-call: 0%, ...
ERROR:   Probable infinite recursion (cycle):
ERROR:     [6,340,556] user:reaches_left(...)
ERROR:     [6,340,555] user:reaches_left(...)
```

## 4.6 The Tracer

```text
?- trace, runs_in(T, reportengine).
   Call: (11) runs_in(_1142, reportengine) ? creep
   Call: (12) top(_1142, _2360) ? creep
   Exit: (12) top(102, 'Table::Find') ? creep
   Call: (12) in_module('Table::Find', reportengine) ? creep
   Exit: (12) in_module('Table::Find', reportengine) ? creep
   Exit: (11) runs_in(102, reportengine) ? creep
T = 102 ;
   Redo: (12) top(_1142, _2360) ? creep
   Exit: (12) top(107, 'Node::Visit') ? creep
   Call: (12) in_module('Node::Visit', reportengine) ? creep
   Exit: (12) in_module('Node::Visit', reportengine) ? creep
   Exit: (11) runs_in(107, reportengine) ? creep
T = 107 ;
   Redo: (12) top(_1142, _2360) ? creep
   Exit: (12) top(109, 'Buffer::Copy') ? creep
   Call: (12) in_module('Buffer::Copy', reportengine) ? creep
   Fail: (12) in_module('Buffer::Copy', reportengine) ? creep
   Fail: (11) runs_in(_1142, reportengine) ? creep
false.
```

## 4.7 Diagnostic Use

```{.prolog .program}
:- [dump1].

% blocked_by(Waiter, Owner): Waiter waits for a
% critical section that Owner owns.
blocked_by(Waiter, Owner) :-
    waits_for(Waiter, critical_section, Addr),
    critical_section(Addr, Owner, _, _),
    Owner \== 0.
```

```{.prolog .query}
?- blocked_by(W, O).
W = 101,
O = 103 ;
W = 103,
O = 104 ;
W = 104,
O = 103.

?- blocked_by(102, O).
false.
```

```{.prolog .query}
?- blocked_by(101, O), blocked_by(O, O2).
O = 103,
O2 = 104.

?- blocked_by(101, O), blocked_by(O, O2),
   blocked_by(O2, O3).
O = O3, O3 = 103,
O2 = 104.
```

```{.prolog .query}
?- blocked_by(A, B), blocked_by(B, A).
A = 103,
B = 104 ;
A = 104,
B = 103.
```

```{.prolog .program}
% blocked_through(TID, Other): TID is blocked by
% Other directly or through a chain of owners.
blocked_through(TID, Other) :-
    blocked_by(TID, Other).
blocked_through(TID, Other) :-
    blocked_by(TID, Owner),
    blocked_through(Owner, Other).
```

```{.prolog .query}
?- blocked_through(101, X).
X = 103 ;
X = 104 ;
X = 103 ;
X = 104 ;
...
```

```{.prolog .program}
% involved(TID, Addr): TID owns or waits for the
% critical section at Addr.
involved(TID, Addr) :-
    (   critical_section(Addr, TID, _, _),
        TID \== 0
    ;   waits_for(TID, critical_section, Addr)
    ).
```

```{.prolog .query}
?- involved(T, 0x7ff6_1d13_a0c0).
T = 103 ;
T = 101 ;
T = 104.

?- involved(T, 0x7ff6_1d13_a1c0).
false.

?- involved(103, A).
A = 140695026507968 ;
A = 140695026508096.
```

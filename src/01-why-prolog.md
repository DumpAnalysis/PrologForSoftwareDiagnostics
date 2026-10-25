# Chapter 1. Logic Programming and Diagnostics

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/01-why-prolog.md`.

## 1.1 Diagnosis as Inference over Artifacts

## 1.2 Facts, Rules, and Queries

```{.prolog .program file=locks.pl}
% owner(CS, TID): critical section CS is
% owned by thread TID.
owner(cs_a, 103).
owner(cs_b, 104).

% waits_for(TID, CS): thread TID waits to
% enter critical section CS.
waits_for(101, cs_a).
waits_for(103, cs_b).
waits_for(104, cs_a).

% blocked_by(Waiter, Owner): Waiter waits
% for a critical section that Owner owns.
blocked_by(Waiter, Owner) :-
    waits_for(Waiter, CS),
    owner(CS, Owner).
```

```{.prolog .query}
?- owner(cs_a, 103).
true.

?- owner(cs_a, 104).
false.
```

```{.prolog .query}
?- owner(cs_a, T).
T = 103.

?- owner(CS, TID).
CS = cs_a,
TID = 103 ;
CS = cs_b,
TID = 104.
```

```{.prolog .query}
?- blocked_by(101, T).
T = 103.

?- blocked_by(T, 103).
T = 101 ;
T = 104.

?- blocked_by(A, B), blocked_by(B, A).
A = 103,
B = 104 ;
A = 104,
B = 103.
```

## 1.3 The Declarative and Procedural Readings

```{.prolog .query}
?- blocked_by(T, 103), write(T), nl.
101
T = 101 ;
104
T = 104.
```

## 1.4 Installing SWI-Prolog

### 1.4.1 Windows

### 1.4.2 macOS

### 1.4.3 Linux

```text
$ swipl --version
SWI-Prolog version 9.0.4 for x86_64-linux
```

### 1.4.4 Editing Files

## 1.5 The Toplevel

```text
$ swipl
Welcome to SWI-Prolog (threaded, 64 bits, version 9.0.4)
...
For built-in help, use ?- help(Topic). or ?- apropos(Word).

?-
```

```{.prolog .query}
?- consult(locks).
true.

?- [locks].
true.
```

```{.prolog .query}
?- make.
true.
```

```{.prolog .query}
?- listing(blocked_by).
blocked_by(Waiter, Owner) :-
    waits_for(Waiter, CS),
    owner(CS, Owner).

true.

?- listing(owner/2).
owner(cs_a, 103).
owner(cs_b, 104).

true.
```

```text
$ swipl locks.pl
Welcome to SWI-Prolog (threaded, 64 bits, version 9.0.4)
...
?- blocked_by(101, T).
T = 103.
```

```text
$ swipl -g "blocked_by(101, T), write(T), nl" -t halt locks.pl
103
```

```text
$ swipl -g "blocked_by(102, T), write(T), nl" -t halt locks.pl
ERROR: -g blocked_by(102, T), write(T), nl: false
$ echo $?
1
$ swipl -g "holder(cs_a, T), write(T), nl" -t halt locks.pl
ERROR: -g holder(cs_a, T), write(T), nl: '<meta-call>'/1:
    Unknown procedure: holder/2
$ echo $?
2
```

## 1.6 Errors and Warnings at Load Time

```text
owner(cs_a, 103).
owner(cs_b 104).
```

```text
ERROR: /home/dv/bad.pl:2:11: Syntax error: Operator expected
```

```{.prolog .query}
?- holder(cs_a, T).
ERROR: Unknown procedure: holder/2 <...>
```

```{.prolog .program .warn file=report.pl}
:- [locks].

% blocked_report(TID): print who blocks TID.
blocked_report(TID) :-
    blocked_by(TID, Owner),
    write(TID),
    write(' is blocked by '),
    write(Ownr),
    nl.
```

```text
Warning: /home/dv/report.pl:4:
Warning:    Singleton variables: [Owner,Ownr]
```

```{.prolog .query}
?- blocked_report(101).
101 is blocked by _<...>
true.
```

```{.prolog .program .fresh file=report.pl}
:- [locks].

% blocked_report(TID): print who blocks TID.
blocked_report(TID) :-
    blocked_by(TID, Owner),
    write(TID),
    write(' is blocked by '),
    write(Owner),
    nl.
```

```{.prolog .query}
?- blocked_report(101).
101 is blocked by 103
true.

?- blocked_report(T).
101 is blocked by 103
T = 101 ;
103 is blocked by 104
T = 103 ;
104 is blocked by 103
T = 104.
```

## 1.7 Diagnostic Use

```{.prolog .program file=threads.pl}
% thread_state(TID, State): the state of thread
% TID at the time of the dump.  State is one of
% running, waiting, suspended.
thread_state(100, waiting).
thread_state(101, waiting).
thread_state(102, running).
thread_state(103, waiting).
thread_state(107, running).
thread_state(108, suspended).
```

```{.prolog .query}
?- thread_state(102, S).
S = running.

?- thread_state(T, running).
T = 102 ;
T = 107.

?- thread_state(T, suspended).
T = 108.
```

```{.prolog .program}
active_thread(TID) :-
    thread_state(TID, running).

passive_thread(TID) :-
    thread_state(TID, waiting).

suspended_thread(TID) :-
    thread_state(TID, suspended).
```

```{.prolog .query}
?- active_thread(T).
T = 102 ;
T = 107.

?- passive_thread(T).
T = 100 ;
T = 101 ;
T = 103.

?- suspended_thread(108).
true.
```

```{.prolog .program}
not_executing(TID) :-
    thread_state(TID, waiting).
not_executing(TID) :-
    thread_state(TID, suspended).
```

```{.prolog .query}
?- not_executing(T).
T = 100 ;
T = 101 ;
T = 103 ;
T = 108.

?- not_executing(103).
true ;
false.
```

```{.prolog .program}
same_state(TID1, TID2) :-
    thread_state(TID1, State),
    thread_state(TID2, State).
```

```{.prolog .query}
?- same_state(102, T).
T = 102 ;
T = 107.

?- same_state(T, 108).
T = 108.
```

```{.prolog .program}
describe(TID) :-
    thread_state(TID, State),
    write(TID),
    write(' is '),
    write(State),
    nl.
```

```{.prolog .query}
?- describe(108).
108 is suspended
true.

?- describe(109).
false.

?- active_thread(T), describe(T).
102 is running
T = 102 ;
107 is running
T = 107.
```

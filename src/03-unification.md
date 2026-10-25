# Chapter 3. Unification

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/03-unification.md`.

## 3.1 Identity and Unifiability

```{.prolog .query}
?- a == a.
true.

?- 1 == 1.0.
false.

?- 'Buffer::Copy' == 'Buffer::Copy'.
true.

?- "abc" == abc.
false.

?- X == Y.
false.

?- X == X.
true.
```

```{.prolog .query}
?- a = b.
false.

?- 1 = 1.0.
false.

?- f(X, b) = f(a, Y).
X = a,
Y = b.

?- X = Y.
X = Y.

?- X = Y, X == Y.
X = Y.
```

```{.prolog .query}
?- f(X) \== f(a).
true.

?- f(X) \= f(a).
false.

?- X \== a.
true.

?- X \= a.
false.
```

## 3.2 How Unification Works

```{.prolog .query}
?- f(X, Y) = f(Y, a).
X = Y, Y = a.

?- f(X, X) = f(a, b).
false.

?- f(X) = f(X, Y).
false.

?- foo(X) = bar(X).
false.

?- f(a, g(X)) = f(Y, g(b)).
X = b,
Y = a.
```

```{.prolog .query}
?- X = 1 + 2.
X = 1+2.

?- X = f(Y), Y = 1.
X = f(1),
Y = 1.
```

## 3.3 Unification as Pattern Matching

```{.prolog .query}
?- frame(T, 0, ntdll, F, _) =
   frame(100, 0, ntdll, 'NtDelayExecution', 20).
T = 100,
F = 'NtDelayExecution'.

?- frame(T, 0, ntdll, F, _) =
   frame(100, 0, kernelbase, 'SleepEx', 158).
false.
```

```{.prolog .query}
?- X = frame(_, 0, ntdll, _, _).
X = frame(_, 0, ntdll, _, _).

?- X = frame(T, N, M, F, O), T = 101, N = 0.
X = frame(101, 0, M, F, O),
T = 101,
N = 0.
```

```{.prolog .query}
?- [H | T] = [ntdll, kernelbase, kernel32].
H = ntdll,
T = [kernelbase, kernel32].

?- [a, b | T] = [a, b].
T = [].
```

## 3.4 The Occurs Check and Cyclic Terms

```{.prolog .query}
?- X = f(X).
X = f(X).

?- X = f(X), cyclic_term(X).
X = f(X).

?- acyclic_term(f(a)).
true.
```

```{.prolog .query}
?- unify_with_occurs_check(X, f(X)).
false.

?- unify_with_occurs_check(f(X, b), f(a, Y)).
X = a,
Y = b.

?- set_prolog_flag(occurs_check, true).
true.

?- X = f(X).
false.

?- set_prolog_flag(occurs_check, error).
true.

?- X = f(X).
ERROR: Cannot unify <...> infinite tree
...

?- set_prolog_flag(occurs_check, false).
true.
```

## 3.5 Deciding Without Binding

```{.prolog .query}
?- ?=(a, a).
true.

?- ?=(f(X), g(Y)).
true.

?- ?=(f(X), f(Y)).
false.

?- ?=(X, a).
false.
```

```{.prolog .query}
?- subsumes_term(f(_), f(a)).
true.

?- subsumes_term(f(a), f(_)).
false.

?- subsumes_term(f(X, X), f(Y, Z)).
false.

?- subsumes_term(f(X, Y), f(Z, Z)).
true.

?- subsumes_term(frame(_, 0, ntdll, _, _),
   frame(100, 0, ntdll, 'NtDelayExecution', 20)).
true.
```

## 3.6 The Variables of a Term, and Copies

```{.prolog .query}
?- term_variables(f(X, g(Y, X), Z), Vs).
Vs = [X, Y, Z].

?- term_variables(frame(T, 0, ntdll, F, _), Vs).
Vs = [T, F, _].

?- term_variables(f(a, b), Vs).
Vs = [].
```

```{.prolog .query}
?- copy_term(f(X, Y, X), C).
C = f(_A, _, _A).

?- copy_term(f(X, Y, X), C), X = a.
X = a,
C = f(_A, _, _A).

?- copy_term(f(a, b), C).
C = f(a, b).
```

## 3.7 Diagnostic Use

```{.prolog .program}
:- [dump1].

% template(Name, Frame): the frame template
% called Name.
template(top_in_ntdll,
         frame(_, 0, ntdll, _, _)).
template(cs_wait,
         frame(_, _, ntdll,
               'RtlEnterCriticalSection', _)).
template(unresolved,
         frame(_, _, _, 'Unknown', _)).
```

```{.prolog .query}
?- frame(T, 0, ntdll, F, _).
T = 100,
F = 'NtWaitForMultipleObjects' ;
T = 101,
F = 'NtWaitForAlertByThreadId' ;
T = 103,
F = 'NtWaitForAlertByThreadId' ;
T = 104,
F = 'NtWaitForAlertByThreadId' ;
T = 105,
F = 'NtWaitForWorkViaWorkerFactory' ;
T = 106,
F = 'NtWaitForWorkViaWorkerFactory' ;
T = 108,
F = 'NtDelayExecution'.
```

```{.prolog .query}
?- frame(T, 0, ntdll, _, _),
   thread_state(T, suspended).
T = 108.

?- frame(T, 0, ntdll, _, _),
   thread_state(T, running).
false.
```

```{.prolog .query}
?- frame(T, 0, M, F, _), M \== ntdll.
T = 102,
M = reportengine,
F = 'Table::Find' ;
T = 107,
M = reportengine,
F = 'Node::Visit' ;
T = 109,
M = dbclient,
F = 'Buffer::Copy'.
```

```{.prolog .query}
?- frame(T, N, ntdll,
   'RtlEnterCriticalSection', _).
T = 101,
N = 3 ;
T = 103,
N = 3 ;
T = 104,
N = 3.
```

```{.prolog .program}
% blocked_thread(TID): TID is blocked entering a
% critical section.
blocked_thread(TID) :-
    frame(TID, _, ntdll,
          'RtlEnterCriticalSection', _).
```

```{.prolog .query}
?- blocked_thread(T).
T = 101 ;
T = 103 ;
T = 104.

?- blocked_thread(102).
false.

?- blocked_thread(T),
   waits_for(T, critical_section, A).
T = 101,
A = 140695026507968 ;
T = 103,
A = 140695026508096 ;
T = 104,
A = 140695026507968.
```

```{.prolog .query}
?- frame(T, 0, M, F, _), frame(T, 1, M, F, _).
T = 107,
M = reportengine,
F = 'Node::Visit' ;
false.
```

```{.prolog .program}
% frame_matches(Name, TID, N): frame N of thread
% TID is an instance of the template called Name.
frame_matches(Name, TID, N) :-
    template(Name, Template),
    frame(TID, N, M, F, O),
    Frame = frame(TID, N, M, F, O),
    subsumes_term(Template, Frame).
```

```{.prolog .query}
?- frame_matches(cs_wait, TID, N).
TID = 101,
N = 3 ;
TID = 103,
N = 3 ;
TID = 104,
N = 3 ;
false.

?- frame_matches(unresolved, TID, N).
TID = 101,
N = 4 ;
false.

?- frame_matches(Name, 108, 0).
Name = top_in_ntdll ;
false.
```

# Chapter 7. Control

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/07-control.md`.

## 7.1 Determinism and Choice Points

```{.prolog .query}
?- member(a, [a, b]).
true ;
false.

?- member(a, [b, a]).
true.
```

```{.prolog .program}
% severity_class(Bits, Class): the class of a
% status code whose two top bits are Bits.
severity_class(0, success).
severity_class(1, informational).
severity_class(2, warning).
severity_class(3, error).

% code_class(Code, Class): Class is the severity
% class of the 32-bit status code Code.
code_class(Code, Class) :-
    Bits is Code >> 30,
    severity_class(Bits, Class).
```

```{.prolog .query}
?- code_class(0xc0000005, C).
C = error.

?- code_class(0x80000003, C).
C = warning.

?- code_class(0, C).
C = success.
```

## 7.2 The Cut

```{.prolog .program}
% max_plain(X, Y, Max): Max is the larger of X, Y.
max_plain(X, Y, X) :-
    X >= Y.
max_plain(X, Y, Y) :-
    X < Y.
```

```{.prolog .query}
?- max_plain(3, 5, M).
M = 5.

?- max_plain(5, 3, M).
M = 5 ;
false.
```

```{.prolog .program}
% max_green(X, Y, Max): Max is the larger of X, Y.
max_green(X, Y, X) :-
    X >= Y,
    !.
max_green(X, Y, Y) :-
    X < Y.
```

```{.prolog .query}
?- max_green(5, 3, M).
M = 5.

?- max_green(3, 5, M).
M = 5.
```

```{.prolog .program}
% max_red(X, Y, Max): Max is the larger of X, Y.
% WRONG: not steadfast.
max_red(X, Y, X) :-
    X >= Y,
    !.
max_red(_, Y, Y).
```

```{.prolog .query}
?- max_red(5, 3, M).
M = 5.

?- max_red(3, 5, M).
M = 5.

?- max_red(5, 3, 3).
true.
```

```{.prolog .program}
% max_of(X, Y, Max): Max is the larger of X and Y.
max_of(X, Y, Max) :-
    X >= Y,
    !,
    Max = X.
max_of(_, Y, Y).
```

```{.prolog .query}
?- max_of(5, 3, 3).
false.

?- max_of(5, 3, M).
M = 5.
```

```{.prolog .query}
?- once(member(X, [a, b, c])).
X = a.

?- ignore(member(x, [a, b, c])).
true.

?- ignore(member(X, [a, b, c])).
X = a.
```

```{.prolog .query}
?- member(kernel32, [ntdll, kernel32, ntdll]).
true ;
false.

?- memberchk(kernel32, [ntdll, kernel32, ntdll]).
true.

?- member(ntdll, [ntdll, kernel32, ntdll]).
true ;
true.

?- memberchk(ntdll, [ntdll, kernel32, ntdll]).
true.
```

## 7.3 If-Then-Else

```{.prolog .query}
?- ( 3 >= 5 -> M = 3 ; M = 5 ).
M = 5.

?- ( member(X, [1, 2, 3]), X > 1
   -> true ; X = none ).
X = 2.

?- ( member(X, [1, 2, 3]), X > 5
   -> true ; X = none ).
X = none.
```

```{.prolog .program}
% larger(X, Y, Max): Max is the larger of X and Y.
larger(X, Y, Max) :-
    (   X >= Y
    ->  Max = X
    ;   Max = Y
    ).
```

```{.prolog .query}
?- larger(5, 3, M).
M = 5.

?- larger(3, 5, M).
M = 5.

?- larger(5, 3, 3).
false.
```

```{.prolog .program}
% cpu_class(Ms, Class): the class of a thread by
% its CPU time in milliseconds.
cpu_class(Ms, Class) :-
    (   Ms >= 1000
    ->  Class = heavy
    ;   Ms > 0
    ->  Class = light
    ;   Class = idle
    ).
```

```{.prolog .query}
?- cpu_class(9680, C).
C = heavy.

?- cpu_class(40, C).
C = light.

?- cpu_class(0, C).
C = idle.
```

```{.prolog .query}
?- ( 3 >= 5 -> M = 3 ).
false.

?- ( 3 >= 5 -> M = 3 ; true ).
true.
```

```{.prolog .query}
?- ( member(X, [1, 2, 3]), X > 1
   *-> true ; X = none ).
X = 2 ;
X = 3.

?- ( member(X, [1, 2, 3]), X > 5
   *-> true ; X = none ).
X = none.
```

```{.prolog .program}
% pred_or_zero(N, P): P is N - 1, or 0 for N = 0.
pred_or_zero(N, P) :-
    (   N > 0
    ->  succ(P, N)
    ;   P = 0
    ).
```

```{.prolog .query}
?- pred_or_zero(5, P).
P = 4.

?- pred_or_zero(0, P).
P = 0.
```

## 7.4 Negation as Failure

```{.prolog .query}
?- \+ member(c, [a, b]).
true.

?- \+ member(a, [a, b]).
false.

?- \+ 1 =:= 2.
true.
```

```{.prolog .query}
?- \+ X = a, X = b.
false.

?- X = b, \+ X = a.
X = b.
```

```{.prolog .query}
?- \+ \+ member(X, [a, b]).
true.

?- \+ \+ member(X, [a, b]), X = c.
X = c.
```

```{.prolog .query}
?- forall(member(X, [1, 2, 3]), X > 0).
true.

?- forall(member(X, [1, 2, 3]), X > 1).
false.

?- forall(member(X, []), X > 1).
true.
```

## 7.5 Loops

```{.prolog .query}
?- member(M, [ntdll, kernel32]),
   write(M), nl, fail.
ntdll
kernel32
false.

?- between(1, 3, N), S is N * N,
   write(S), nl, fail.
1
4
9
false.
```

```{.prolog .query}
?- forall(member(M, [ntdll, kernel32]),
   ( write(M), nl )).
ntdll
kernel32
true.
```

```prolog
% read_all_terms: read and print every term on the
% current input stream.
read_all_terms :-
    repeat,
    read(Term),
    (   Term == end_of_file
    ->  !
    ;   print(Term), nl,
        fail
    ).
```

## 7.6 Exceptions

```{.prolog .query}
?- catch(throw(my_ball), Ball, true).
Ball = my_ball.

?- catch(throw(my_ball), other, true).
ERROR: Unhandled exception: <...>
...

?- catch(member(X, [a, b]), _, true).
X = a ;
X = b.

?- catch(fail, _, true).
false.
```

```{.prolog .query}
?- catch(X is 1 / 0, error(E, _), true).
E = evaluation_error(zero_divisor).

?- catch(X is foo + 1, error(E, _), true).
E = type_error(evaluable, foo/0).

?- catch(atom_length(X, L), error(E, _), true).
E = instantiation_error.

?- catch(X is 1 / 0, error(_, Context), true).
Context = context((/)/2, _).
```

```{.prolog .query}
?- catch(must_be(integer, a), error(E, _), true).
E = type_error(integer, a).

?- catch(must_be(integer, X), error(E, _), true).
E = instantiation_error.

?- catch(must_be(positive_integer, 0),
   error(E, _), true).
E = type_error(positive_integer, 0).

?- must_be(integer, a).
ERROR: Type error: `integer' expected, <...>
...

?- catch(existence_error(thread, 999),
   error(E, _), true).
E = existence_error(thread, 999).
```

```{.prolog .program}
% call_missing(E): E is the formal error term
% raised by a goal for an undefined predicate.
call_missing(E) :-
    catch(missing(1), error(E, _), true).
```

```{.prolog .query}
?- call_missing(E).
E = existence_error(procedure, missing/1).
```

```{.prolog .query}
?- setup_call_cleanup(true, member(X, [a, b]),
   (write(cleanup), nl)).
X = a ;
cleanup
X = b.

?- setup_call_cleanup(true, fail,
   (write(cleanup), nl)).
cleanup
false.

?- catch(setup_call_cleanup(true, throw(oops),
   (write(cleanup), nl)), B, true).
cleanup
B = oops.

?- print_message(error,
   error(type_error(integer, a), _)).
ERROR: Type error: `integer' expected, <...>
true.
```

## 7.7 Diagnostic Use

```{.prolog .program}
:- [dump1].
```

```{.prolog .query}
?- exception_record(109, Code, _),
   code_class(Code, C).
Code = 3221225477,
C = error.
```

```{.prolog .program}
% thread_class(TID, Class): Class is the one class
% of thread TID, by the first condition to hold.
thread_class(TID, Class) :-
    thread(TID, _),
    class_of(TID, Class).

% class_of(TID, Class): as thread_class/2, for a
% TID known to be a thread of the dump.
class_of(TID, Class) :-
    (   exception_record(TID, _, _)
    ->  Class = faulting
    ;   waits_for(TID, _, _)
    ->  Class = blocked
    ;   thread_state(TID, running)
    ->  Class = running
    ;   thread_state(TID, suspended)
    ->  Class = suspended
    ;   frame(TID, _, ntdll, 'TppWorkerThread', _)
    ->  Class = pool_idle
    ;   Class = waiting
    ).
```

```{.prolog .query}
?- thread_class(109, C).
C = faulting.

?- thread_class(101, C).
C = blocked.

?- thread_class(105, C).
C = pool_idle.

?- thread_class(100, C).
C = waiting.

?- thread_class(999, C).
false.
```

```{.prolog .query}
?- thread_class(T, C).
T = 100,
C = waiting ;
T = 101,
C = blocked ;
T = 102,
C = running ;
T = 103,
C = blocked ;
T = 104,
C = blocked ;
T = 105,
C = pool_idle ;
T = 106,
C = pool_idle ;
T = 107,
C = running ;
T = 108,
C = suspended ;
T = 109,
C = faulting.

?- thread_class(T, blocked).
T = 101 ;
T = 103 ;
T = 104 ;
false.
```

```{.prolog .program}
% lookup_class(TID, Class): as thread_class/2 for
% a bound TID; an error on a non-integer or an
% absent TID.
lookup_class(TID, Class) :-
    must_be(integer, TID),
    (   thread(TID, _)
    ->  class_of(TID, Class)
    ;   existence_error(thread, TID)
    ).
```

```{.prolog .query}
?- lookup_class(102, C).
C = running.

?- catch(lookup_class(999, C), error(E, _), true).
E = existence_error(thread, 999).

?- catch(lookup_class(abc, C), error(E, _), true).
E = type_error(integer, abc).

?- lookup_class(999, C).
ERROR: thread `999' does not exist
...
```

```{.prolog .program}
% stack_trace(TID, Frames): Frames is the list of
% frame/5 terms of thread TID, top frame first.
stack_trace(TID, Frames) :-
    frames_from(TID, 0, Frames).

% frames_from(TID, N, Frames): Frames is the list
% of frames of TID numbered N and above.
frames_from(TID, N, Frames) :-
    (   frame(TID, N, M, F, O)
    ->  Frames = [frame(TID, N, M, F, O) | Rest],
        succ(N, N1),
        frames_from(TID, N1, Rest)
    ;   Frames = []
    ).
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.

?- stack_trace(100, _Frames), length(_Frames, N).
N = 7.

?- stack_trace(107, _Frames), length(_Frames, N).
N = 14.

?- stack_trace(999, Frames).
Frames = [].
```

```{.prolog .program}
% top_run(TID, Function, Count): the top Count
% frames of TID all name Function, and frame Count
% does not.
top_run(TID, Function, Count) :-
    frame(TID, 0, _, Function, _),
    run_from(TID, 1, Function, 1, Count).

% run_from(TID, N, Function, Acc0, Count): Count
% is Acc0 plus the frames from N on that continue
% the run of Function.
run_from(TID, N, Function, Acc0, Count) :-
    (   frame(TID, N, _, Function, _)
    ->  Acc is Acc0 + 1,
        succ(N, N1),
        run_from(TID, N1, Function, Acc, Count)
    ;   Count = Acc0
    ).
```

```{.prolog .query}
?- top_run(107, F, N).
F = 'Node::Visit',
N = 8.

?- top_run(101, F, N).
F = 'NtWaitForAlertByThreadId',
N = 1.

?- top_run(T, F, N), N > 1.
T = 107,
F = 'Node::Visit',
N = 8 ;
false.
```

```{.prolog .program}
% thread_last_error(TID, Code): Code is the last
% error code recorded for TID, or unrecorded.
thread_last_error(TID, Code) :-
    must_be(integer, TID),
    (   last_error(TID, Code0)
    ->  Code = Code0
    ;   Code = unrecorded
    ).

% module_company(Module, Company): Company is the
% vendor recorded for Module, or unrecorded.
module_company(Module, Company) :-
    must_be(atom, Module),
    (   module_info(Module, company, Company0)
    ->  Company = Company0
    ;   Company = unrecorded
    ).
```

```{.prolog .query}
?- thread_last_error(109, C).
C = 998.

?- thread_last_error(105, C).
C = unrecorded.

?- catch(thread_last_error(x, C),
   error(E, _), true).
E = type_error(integer, x).

?- module_company(thirdparty_hook, C).
C = 'Unknown'.

?- module_company(ntdll, C).
C = unrecorded.

?- module_company(appserver, C).
C = 'Example Corp'.
```

```{.prolog .program}
% well_formed(Frame): Frame is a frame/5 term
% whose arguments have the kinds the schema
% prescribes.
well_formed(frame(TID, N, M, F, O)) :-
    integer(TID),
    integer(N),
    atom(M),
    atom(F),
    integer(O).
```

```{.prolog .query}
?- frame(T, N, M, F, O),
   \+ well_formed(frame(T, N, M, F, O)).
false.

?- forall(frame(T, N, M, F, O),
   well_formed(frame(T, N, M, F, O))).
true.

?- forall(frame(_, _, M, _, _), module(M, _, _)).
true.

?- forall(waits_for(T, _, _),
   thread_state(T, waiting(user_request))).
true.

?- forall(thread_state(T, waiting(_)),
   frame(T, 0, ntdll, _, _)).
false.

?- thread_state(T, waiting(_)),
   \+ frame(T, 0, ntdll, _, _).
T = 109.
```

```{.prolog .program}
% unreferenced_module(M): M is loaded and appears
% in no frame of any stack trace.
unreferenced_module(M) :-
    module(M, _, _),
    \+ frame(_, _, M, _, _).

% idle_thread(TID): TID has no exception, waits
% for nothing recorded, and was not running.
idle_thread(TID) :-
    thread(TID, _),
    \+ exception_record(TID, _, _),
    \+ waits_for(TID, _, _),
    \+ thread_state(TID, running).
```

```{.prolog .query}
?- unreferenced_module(M).
M = msvcp140 ;
M = thirdparty_hook.

?- idle_thread(T).
T = 100 ;
T = 105 ;
T = 106 ;
T = 108 ;
false.
```

```{.prolog .program}
% print_thread_classes: one line per thread with
% its class and CPU time.
print_thread_classes :-
    forall(thread_class(TID, Class),
           ( thread_time(TID, U, K),
             Ms is U + K,
             format("~d~t~6|~a~t~16|~t~d~6+ ms~n",
                    [TID, Class, Ms])
           )).
```

```{.prolog .query}
?- print_thread_classes.
100   waiting      160 ms
101   blocked       20 ms
102   running     9680 ms
103   blocked       40 ms
104   blocked       35 ms
105   pool_idle     25 ms
106   pool_idle     15 ms
107   running     4100 ms
108   suspended      0 ms
109   faulting      60 ms
true.
```

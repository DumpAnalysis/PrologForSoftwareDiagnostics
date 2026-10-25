# Chapter 2. Terms

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/02-terms.md`.

## 2.1 Atoms

```{.prolog .query}
?- atom(ntdll).
true.

?- atom('Buffer::Copy').
true.

?- atom(NtWaitForMultipleObjects).
false.
```

```{.prolog .query}
?- write('Buffer::Copy'), nl.
Buffer::Copy
true.

?- write_canonical('Buffer::Copy'), nl.
'Buffer::Copy'
true.

?- write_canonical('123'), nl.
'123'
true.
```

```{.prolog .query}
?- atom([]).
false.

?- atom('[]').
true.

?- atom({}).
true.

?- atomic([]).
true.
```

## 2.2 Numbers

```{.prolog .query}
?- integer(0x1a).
true.

?- write(0x1a), nl.
26
true.

?- write(0x7ffb_b2a0_0000), nl.
140719010349056
true.

?- write(0'A), nl.
65
true.
```

```{.prolog .query}
?- integer(18446744073709551616).
true.

?- current_prolog_flag(bounded, F).
F = false.
```

```{.prolog .query}
?- float(1.0).
true.

?- float(1).
false.

?- write(1.0e3), nl.
1000.0
true.
```

```{.prolog .query}
?- number(-5).
true.

?- number(- 5).
false.

?- write_canonical(- 5), nl.
-(5)
true.
```

## 2.3 Variables

```{.prolog .query}
?- var(X).
true.

?- nonvar(X).
false.

?- var(ntdll).
false.
```

```{.prolog .program}
% module_of(Frame, Module): Module is the module
% argument of the frame term Frame.
module_of(frame(_TID, _N, Module, _F, _Off),
          Module).
```

```{.prolog .query}
?- module_of(frame(109, 0, dbclient,
       'Buffer::Copy', 26), M).
M = dbclient.

?- module_of(thread(100, 4120), M).
false.
```

```{.prolog .query}
?- write_canonical(f(X, Y, X)), nl.
f(A,_,A)
true.
```

## 2.4 Compound Terms

```{.prolog .query}
?- compound(waiting(user_request)).
true.

?- compound(ntdll).
false.

?- write_canonical(waiting(user_request)), nl.
waiting(user_request)
true.
```

```{.prolog .query}
?- ground(frame(109, 0, dbclient,
       'Buffer::Copy', 26)).
true.

?- ground(frame(_, 0, ntdll, _, _)).
false.
```

## 2.5 Operators and Canonical Form

```{.prolog .query}
?- write_canonical(1 + 2 * 3), nl.
+(1,*(2,3))
true.

?- write_canonical((1 + 2) * 3), nl.
*(+(1,2),3)
true.

?- write_canonical((a :- b, c)), nl.
:-(a,','(b,c))
true.
```

```{.prolog .query}
?- write(+(1, *(2, 3))), nl.
1+2*3
true.

?- write(*(+(1, 2), 3)), nl.
(1+2)*3
true.
```

## 2.6 Lists

```{.prolog .query}
?- write_canonical([1, 2, 3]), nl.
[1,2,3]
true.

?- display([1, 2, 3]), nl.
'[|]'(1,'[|]'(2,'[|]'(3,[])))
true.

?- write_canonical('[|]'(1, [])), nl.
[1]
true.
```

```{.prolog .query}
?- compound([1]).
true.

?- compound([]).
false.

?- is_list([1, 2, 3]).
true.

?- is_list([1 | T]).
false.

?- write_canonical([a, b | T]), nl.
[a,b|_]
true.
```

## 2.7 Strings, Code Lists, and Char Lists

```{.prolog .query}
?- string("Query end").
true.

?- atom("Query end").
false.

?- write("Query end"), nl.
Query end
true.

?- write_canonical("Query end"), nl.
"Query end"
true.

?- write_canonical(`abc`), nl.
[97,98,99]
true.
```

```{.prolog .query}
?- current_prolog_flag(double_quotes, F).
F = string.

?- is_list("abc").
false.
```

## 2.8 Type Tests

```{.prolog .query}
?- atomic("abc").
true.

?- atomic(X).
false.

?- callable(foo(1)).
true.

?- callable([]).
false.
```

## 2.9 The Standard Order of Terms

```{.prolog .query}
?- compare(O, 1, a).
O = (<).

?- compare(O, a, "a").
O = (>).

?- compare(O, 1.0, 1).
O = (<).

?- compare(O, f(a, b), g(a)).
O = (>).

?- compare(O, f(a), g(a)).
O = (<).
```

```{.prolog .query}
?- compare(O, frame(101, 2, ntdll, f, 0),
       frame(101, 10, ntdll, f, 0)).
O = (<).

?- compare(O, frame(102, 0, ntdll, f, 0),
       frame(101, 9, ntdll, f, 0)).
O = (>).
```

```{.prolog .query}
?- compare(O, 10, 9).
O = (>).

?- compare(O, '10', '9').
O = (<).
```

## 2.10 Artifacts as Terms

```prolog
module(dbclient, 0x7ffb_8d10_0000, 0x6e000).
frame(109, 0, dbclient, 'Buffer::Copy', 0x1a).
thread_state(109, waiting(exception)).
exception_record(109, 0xc0000005,
                 0x7ffb_8d10_31aa).
msg(69, 14.002, 4120, 109, dbclient,
    "Error: buffer copy failed, code=0x3e6").
```

## 2.11 Diagnostic Use

```{.prolog .program}
:- [dump1].
```

```{.prolog .query}
?- frame(109, 0, M, F, O).
M = dbclient,
F = 'Buffer::Copy',
O = 26.

?- frame(101, 4, M, F, O).
M = cachelib,
F = 'Unknown',
O = 10768.
```

```{.prolog .query}
?- frame(101, 0, M, F, O),
   write_canonical(frame(101, 0, M, F, O)), nl.
frame(101,0,ntdll,'NtWaitForAlertByThreadId',20)
M = ntdll,
F = 'NtWaitForAlertByThreadId',
O = 20.
```

```{.prolog .program}
% well_formed_frame(TID, N): frame N of thread TID
% has the argument types the schema prescribes.
well_formed_frame(TID, N) :-
    frame(TID, N, Module, Function, Offset),
    integer(TID),
    integer(N),
    atom(Module),
    atom(Function),
    integer(Offset).
```

```{.prolog .query}
?- well_formed_frame(109, 0).
true.

?- well_formed_frame(101, 4).
true.

?- frame(T, N, _, F, _), string(F).
false.
```

```{.prolog .query}
?- frame(T, N, M, 'Unknown', _).
T = 101,
N = 4,
M = cachelib.
```

```{.prolog .query}
?- module_info(cachelib, symbols, S).
S = none ;
false.

?- module_info(M, symbols, none).
M = cachelib ;
M = thirdparty_hook.
```

```{.prolog .program}
no_component_symbols(Module) :-
    module_info(Module, symbols, none).
```

```{.prolog .query}
?- no_component_symbols(M).
M = cachelib ;
M = thirdparty_hook.

?- no_component_symbols(ntdll).
false.
```

```{.prolog .program}
unknown_component(Module) :-
    module_info(Module, company, 'Unknown').
```

```{.prolog .query}
?- unknown_component(M).
M = thirdparty_hook.

?- module_info(thirdparty_hook, K, V).
K = version,
V = '1.0.0.1' ;
K = symbols,
V = none ;
K = company,
V = 'Unknown'.
```

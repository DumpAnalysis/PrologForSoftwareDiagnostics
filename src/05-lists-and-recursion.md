# Chapter 5. Lists and Recursion

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/05-lists-and-recursion.md`.

## 5.1 Lists as Terms

```{.prolog .query}
?- [H | T] = [ntdll, kernelbase, kernel32].
H = ntdll,
T = [kernelbase, kernel32].

?- [H | T] = [ntdll].
H = ntdll,
T = [].

?- [H | T] = [].
false.

?- [a, b | T] = [a, b, c, d].
T = [c, d].
```

```{.prolog .query}
?- L = [1, 2 | T], T = [3].
L = [1, 2, 3],
T = [3].

?- is_list([a | T]).
false.

?- length([a | T], 3).
T = [_, _].
```

## 5.2 Recursion over Lists

```{.prolog .program}
% list_member(X, List): X is an element of List.
list_member(X, [X | _]).
list_member(X, [_ | T]) :-
    list_member(X, T).
```

```{.prolog .query}
?- list_member(X, [ntdll, kernel32, ntdll]).
X = ntdll ;
X = kernel32 ;
X = ntdll ;
false.

?- list_member(kernel32, [ntdll, kernel32]).
true ;
false.

?- list_member(appserver, [ntdll, kernel32]).
false.
```

```{.prolog .query}
?- member(X, [ntdll, kernel32, ntdll]).
X = ntdll ;
X = kernel32 ;
X = ntdll.

?- member(kernel32, [ntdll, kernel32]).
true.

?- member(ntdll, [ntdll, kernel32, ntdll]).
true ;
true.
```

```{.prolog .program}
% list_append(Xs, Ys, Zs): Zs is the concatenation
% of Xs and Ys.
list_append([], Ys, Ys).
list_append([X | Xs], Ys, [X | Zs]) :-
    list_append(Xs, Ys, Zs).
```

```{.prolog .query}
?- list_append([a, b], [c], Zs).
Zs = [a, b, c].

?- list_append(Xs, Ys, [a, b, c]).
Xs = [],
Ys = [a, b, c] ;
Xs = [a],
Ys = [b, c] ;
Xs = [a, b],
Ys = [c] ;
Xs = [a, b, c],
Ys = [] ;
false.

?- list_append(Xs, [c], [a, b, c]).
Xs = [a, b] ;
false.
```

```{.prolog .program}
% without_module(Ms, M, Rest): Rest is Ms without
% the occurrences of module M.
without_module([], _, []).
without_module([M | Ms], M, Rest) :-
    without_module(Ms, M, Rest).
without_module([M0 | Ms], M, [M0 | Rest]) :-
    M0 \== M,
    without_module(Ms, M, Rest).
```

```{.prolog .query}
?- without_module([ntdll, kernel32, ntdll,
   appserver], ntdll, Rest).
Rest = [kernel32, appserver] ;
false.
```

```{.prolog .program}
% leading_run(List, X, Run): Run is the longest
% prefix of List all of whose elements are X.
leading_run([], _, []).
leading_run([X | Xs], X, [X | Run]) :-
    leading_run(Xs, X, Run).
leading_run([Y | _], X, []) :-
    Y \== X.
```

```{.prolog .query}
?- leading_run([a, a, b, a], a, Run).
Run = [a, a] ;
false.

?- leading_run([a, a, b, a], X, Run).
X = a,
Run = [a, a] ;
Run = [].
```

## 5.3 The List Library

```{.prolog .query}
?- length([a, b, c], N).
N = 3.

?- length(L, 2).
L = [_, _].

?- length(L, N).
L = [],
N = 0 ;
L = [_],
N = 1 ;
L = [_, _],
N = 2 ;
...
```

```{.prolog .query}
?- nth0(1, [a, b, c], X).
X = b.

?- nth1(1, [a, b, c], X).
X = a.

?- nth0(I, [a, b, a], a).
I = 0 ;
I = 2.

?- last([a, b, c], X).
X = c.
```

```{.prolog .query}
?- msort([c, a, b, a], L).
L = [a, a, b, c].

?- sort([c, a, b, a], L).
L = [a, b, c].

?- sort(0, @>=, [c, a, b, a], L).
L = [c, b, a, a].

?- sort(1, @<, [f(2, a), f(1, b), f(2, c)], L).
L = [f(1, b), f(2, a)].

?- sort(1, @=<, [f(2, a), f(1, b), f(2, c)], L).
L = [f(1, b), f(2, a), f(2, c)].

?- msort([ntdll, 10, "s", f(a), 2.0, X], L).
L = [X, 2.0, 10, "s", ntdll, f(a)].
```

```{.prolog .query}
?- sum_list([120, 15, 8450], S).
S = 8585.

?- max_list([120, 15, 8450], M).
M = 8450.

?- max_list([], M).
false.

?- numlist(0, 4, L).
L = [0, 1, 2, 3, 4].
```

```{.prolog .query}
?- select(X, [a, b, c], Rest).
X = a,
Rest = [b, c] ;
X = b,
Rest = [a, c] ;
X = c,
Rest = [a, b].

?- subtract([a, b, c, d], [b, d], R).
R = [a, c].

?- intersection([a, b, c], [c, a, x], R).
R = [a, c].

?- union([a, b], [b, c], R).
R = [a, b, c].

?- list_to_set([a, b, a, c, b], S).
S = [a, b, c].

?- delete([f(1), f(2), g(1)], f(_), R).
R = [g(1)].
```

## 5.4 Accumulators and Tail Recursion

```{.prolog .program}
% naive_reverse(Xs, Ys): Ys is Xs reversed.
naive_reverse([], []).
naive_reverse([X | Xs], Ys) :-
    naive_reverse(Xs, Zs),
    list_append(Zs, [X], Ys).
```

```{.prolog .program}
% reverse_acc(Xs, Acc, Ys): Ys is Xs reversed,
% followed by Acc.
reverse_acc([], Ys, Ys).
reverse_acc([X | Xs], Acc, Ys) :-
    reverse_acc(Xs, [X | Acc], Ys).

% list_reverse(Xs, Ys): Ys is Xs reversed.
list_reverse(Xs, Ys) :-
    reverse_acc(Xs, [], Ys).
```

```{.prolog .query}
?- list_reverse([a, b, c], Ys).
Ys = [c, b, a].

?- reverse_acc([a, b], [x], Ys).
Ys = [b, a, x].
```

## 5.5 Difference Lists

```{.prolog .program}
% dl_append(Xs, Ys, Zs): the difference list Zs is
% Xs followed by Ys.
dl_append(Front-Mid, Mid-Back, Front-Back).
```

```{.prolog .query}
?- dl_append([a, b | H1]-H1, [c | H2]-H2, Zs).
H1 = [c|H2],
Zs = [a, b, c|H2]-H2.

?- dl_append([a, b | H1]-H1, [c | H2]-H2, L-[]).
H1 = [c],
H2 = [],
L = [a, b, c].
```

## 5.6 Diagnostic Use

```{.prolog .program}
:- [dump1].
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.
```

```{.prolog .program}
% stack_trace(TID, Frames): Frames is the list of
% frame/5 terms of thread TID, top frame first.
stack_trace(TID, Frames) :-
    frames_from(TID, 0, Frames).

% frames_from(TID, N, Frames): Frames is the list
% of frames of TID numbered N and above.
frames_from(TID, N,
            [frame(TID, N, M, F, O) | Frames]) :-
    frame(TID, N, M, F, O),
    succ(N, N1),
    frames_from(TID, N1, Frames).
frames_from(TID, N, []) :-
    \+ frame(TID, N, _, _, _).
```

```{.prolog .query}
?- succ(3, N).
N = 4.

?- succ(N, 4).
N = 3.

?- \+ frame(100, 7, _, _, _).
true.

?- stack_trace(100, _Frames), length(_Frames, N).
N = 7 ;
false.

?- stack_trace(999, Frames).
Frames = [].
```

```{.prolog .program}
% frame_symbols(Frames, Symbols): Symbols is the
% list of Module-Function pairs of Frames.
frame_symbols([], []).
frame_symbols([frame(_, _, M, F, _) | Frames],
              [M-F | Symbols]) :-
    frame_symbols(Frames, Symbols).

% print_symbols(Symbols): print one
% Module!Function pair per line.
print_symbols([]).
print_symbols([M-F | Symbols]) :-
    write(M), write('!'), write(F), nl,
    print_symbols(Symbols).

% print_stack_trace(TID): print the stack trace of
% TID in the debugger's module!function form.
print_stack_trace(TID) :-
    stack_trace(TID, Frames),
    frame_symbols(Frames, Symbols),
    print_symbols(Symbols).
```

```{.prolog .query}
?- print_stack_trace(109).
dbclient!Buffer::Copy
dbclient!Connection::Receive
appserver!Session::Fetch
appserver!Worker::Run
ucrtbase!thread_start<...>
kernel32!BaseThreadInitThunk
ntdll!RtlUserThreadStart
true ;
false.
```

```{.prolog .query}
?- stack_trace(107, _Frames), length(_Frames, N).
N = 14 ;
false.

?- stack_trace(107, _Frames),
   frame_symbols(_Frames, _Symbols),
   leading_run(_Symbols, Symbol, _Run),
   length(_Run, N).
Symbol = reportengine-'Node::Visit',
N = 8 ;
N = 0 ;
false.

?- stack_trace(101, _Frames),
   frame_symbols(_Frames, _Symbols),
   leading_run(_Symbols, _, _Run),
   length(_Run, N).
N = 1 ;
N = 0 ;
false.
```

```{.prolog .program}
% frame_modules(Frames, Modules): Modules is the
% list of module names of Frames, in frame order.
frame_modules([], []).
frame_modules([frame(_, _, M, _, _) | Frames],
              [M | Modules]) :-
    frame_modules(Frames, Modules).
```

```{.prolog .query}
?- stack_trace(105, _Frames),
   frame_modules(_Frames, Ms).
Ms = [ntdll, ntdll, kernel32, ntdll] ;
false.

?- stack_trace(105, _Frames),
   frame_modules(_Frames, _Ms), sort(_Ms, Set).
Set = [kernel32, ntdll] ;
false.

?- stack_trace(105, _Frames),
   frame_modules(_Frames, _Ms),
   list_to_set(_Ms, Set).
Set = [ntdll, kernel32] ;
false.
```

```{.prolog .program}
% common_suffix(Xs, Ys, Suffix): Suffix is a
% suffix of both Xs and Ys; the longest is first.
common_suffix(Xs, Ys, Suffix) :-
    append(_, Suffix, Xs),
    append(_, Suffix, Ys).

% common_tail(TID1, TID2, Symbols): Symbols is a
% common suffix of the two threads' stack traces.
common_tail(TID1, TID2, Symbols) :-
    stack_trace(TID1, Frames1),
    stack_trace(TID2, Frames2),
    frame_symbols(Frames1, Symbols1),
    frame_symbols(Frames2, Symbols2),
    common_suffix(Symbols1, Symbols2, Symbols).
```

```{.prolog .query}
?- common_tail(101, 103, _S),
   print_symbols(_S), length(_S, N).
appserver!Worker::Run
ucrtbase!thread_start<...>
kernel32!BaseThreadInitThunk
ntdll!RtlUserThreadStart
N = 4 ;
ucrtbase!thread_start<...>
kernel32!BaseThreadInitThunk
ntdll!RtlUserThreadStart
N = 3 ;
...

?- common_tail(101, 104, _S),
   print_symbols(_S), length(_S, N).
ucrtbase!thread_start<...>
kernel32!BaseThreadInitThunk
ntdll!RtlUserThreadStart
N = 3 ;
...
```

```{.prolog .program}
% blocked_by(Waiter, Owner): Waiter waits for a
% critical section that Owner owns.
blocked_by(Waiter, Owner) :-
    waits_for(Waiter, critical_section, Addr),
    critical_section(Addr, Owner, _, _),
    Owner \== 0.

% blocked_through(TID, Other): Other blocks TID
% directly or through a chain of owners.
blocked_through(TID, Other) :-
    blocked_through(TID, [TID], Other).

% blocked_through(TID, Visited, Other): as above,
% never passing through a thread in Visited.
blocked_through(TID, Visited, Other) :-
    blocked_by(TID, Other),
    \+ member(Other, Visited).
blocked_through(TID, Visited, Other) :-
    blocked_by(TID, Owner),
    \+ member(Owner, Visited),
    blocked_through(Owner, [Owner | Visited],
                    Other).
```

```{.prolog .query}
?- blocked_through(101, T).
T = 103 ;
T = 104 ;
false.

?- blocked_through(103, T).
T = 104 ;
false.

?- blocked_through(103, 103).
false.
```

```{.prolog .program}
% frames_dl(TID, N, Frames, Hole): Frames is the
% frames of TID from N on, followed by Hole.
frames_dl(TID, N,
          [frame(TID, N, M, F, O) | Frames],
          Hole) :-
    frame(TID, N, M, F, O),
    succ(N, N1),
    frames_dl(TID, N1, Frames, Hole).
frames_dl(TID, N, Hole, Hole) :-
    \+ frame(TID, N, _, _, _).

% two_stack_traces(TID1, TID2, Frames): the frames
% of TID1 followed by those of TID2.
two_stack_traces(TID1, TID2, Frames) :-
    frames_dl(TID1, 0, Frames, Hole),
    frames_dl(TID2, 0, Hole, []).
```

```{.prolog .query}
?- two_stack_traces(105, 106, _Frames),
   length(_Frames, N).
N = 8 ;
false.

?- two_stack_traces(105, 106, _Frames),
   frame_modules(_Frames, _Ms),
   list_to_set(_Ms, Set).
Set = [ntdll, kernel32] ;
false.
```

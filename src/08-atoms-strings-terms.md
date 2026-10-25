# Chapter 8. Atoms, Strings, and Term Inspection

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/08-atoms-strings-terms.md`.

## 8.1 Text in Four Forms

```{.prolog .query}
?- atom_codes(ntdll, Cs).
Cs = [110, 116, 100, 108, 108].

?- atom_chars(ntdll, Cs).
Cs = [n, t, d, l, l].

?- atom_codes(A, [0'n, 0't]).
A = nt.

?- atom_string(A, "ntdll").
A = ntdll.

?- string_chars(S, [a, b]).
S = "ab".

?- char_code(C, 0'a).
C = a.
```

```{.prolog .query}
?- atom_number('0x1a', N).
N = 26.

?- atom_number('1a', N).
false.

?- atom_number(A, 26).
A = '26'.

?- number_string(N, "44").
N = 44.

?- number_string(N, "44 ms").
false.
```

```{.prolog .query}
?- atom_length('Buffer::Copy', L).
L = 12.

?- atom_length(12345, L).
L = 5.

?- string_length("Query end", L).
L = 9.
```

```{.prolog .query}
?- downcase_atom('NTDLL', D).
D = ntdll.

?- string_lower("Buffer::Copy", L).
L = "buffer::copy".
```

## 8.2 Concatenation, Substrings, and Splitting

```{.prolog .query}
?- atom_concat(dbclient, '!Buffer::Copy', A).
A = 'dbclient!Buffer::Copy'.

?- atom_concat(X, '!Buffer::Copy',
   'dbclient!Buffer::Copy').
X = dbclient.

?- atom_concat(X, Y, abc).
X = '',
Y = abc ;
X = a,
Y = bc ;
X = ab,
Y = c ;
X = abc,
Y = ''.

?- string_concat(X, "end", "Query end").
X = "Query ".
```

```{.prolog .query}
?- atomic_list_concat([dbclient, '!', 'Copy'], A).
A = 'dbclient!Copy'.

?- atomic_list_concat([a, 1, "s", 2.5], A).
A = 'a1s2.5'.

?- atomic_list_concat([a, b, c], '::', A).
A = 'a::b::c'.

?- atomic_list_concat(Parts, '::', 'a::b::c').
Parts = [a, b, c].

?- atomic_list_concat(Parts, ' ', 'end: 1 row').
Parts = ['end:', '1', row].
```

```{.prolog .query}
?- sub_atom(abcde, 1, 3, A, Sub).
A = 1,
Sub = bcd.

?- sub_atom(abcde, B, 2, 0, Sub).
B = 3,
Sub = de.

?- sub_atom('dbclient!Copy', B, _, A, '!').
B = 8,
A = 4 ;
false.

?- sub_atom('a::b::c', B, 2, A, '::').
B = 1,
A = 4 ;
B = 4,
A = 1 ;
false.

?- sub_atom('RtlUserThreadStart', 0, 3, _, P).
P = 'Rtl'.

?- sub_atom('BaseThreadInitThunk', _, _, 0,
   'Thunk').
true.

?- sub_string("Query end: 1 row, 44 ms", B, _, 0,
   "ms").
B = 21.
```

```{.prolog .query}
?- split_string("end: 1 row, 44 ms", " ", "", P).
P = ["end:", "1", "row,", "44", "ms"].

?- split_string("end: 1 row, 44 ms", " ", ",:",
   P).
P = ["end", "1", "row", "44", "ms"].

?- split_string("end: 1 row, 44 ms", " ,:", "",
   P).
P = ["end", "", "1", "row", "", "44", "ms"].

?- split_string("end: 1 row, 44 ms", " ,:", " ,:",
   P).
P = ["end", "1", "row", "44", "ms"].

?- split_string("  padded  ", "", " ", P).
P = ["padded"].

?- split_string("Request 1 done: 200, 309 ms",
   ",", " ", P).
P = ["Request 1 done: 200", "309 ms"].
```

```{.prolog .query}
?- split_string("end: 1 row, 44 ms", " ", ",:",
   P), nth1(4, P, S), number_string(N, S).
P = ["end", "1", "row", "44", "ms"],
S = "44",
N = 44.
```

```{.prolog .query}
?- string_code(1, "abc", C), char_code(Ch, C).
C = 97,
Ch = a.

?- string_code(I, "abc", 0'c).
I = 3.

?- string_code(4, "abc", C).
false.
```

## 8.3 Terms as Text

```{.prolog .query}
?- term_to_atom(frame(109, 0, 'Copy', 0x1a), A).
A = 'frame(109,0,\'Copy\',26)'.

?- term_string(T, "frame(109, 0, 'Copy', 0x1a)").
T = frame(109, 0, 'Copy', 26).

?- term_string(T, "foo(X, Y, X)").
T = foo(_A, _, _A).
```

```{.prolog .query}
?- read_term_from_atom('f(X, Y)', T,
   [variable_names(Vs)]).
T = f(_A, _B),
Vs = ['X'=_A, 'Y'=_B].
```

```{.prolog .query}
?- format(atom(A), "~a!~a+0x~16r",
   [dbclient, 'Buffer::Copy', 26]).
A = 'dbclient!Buffer::Copy+0x1a'.

?- format(string(S), "~`0t~16r~16|",
   [0x7ffb_8d10_31aa]).
S = "00007ffb8d1031aa".

?- format(atom(A), "0x~16r", [0xc0000005]),
   atom_number(A, N).
A = '0xc0000005',
N = 3221225477.
```

```{.prolog .query}
?- with_output_to(string(S),
   forall(member(X, [a, b]), (write(X), nl))).
S = "a\nb\n".
```

```{.prolog .query}
?- print([a, 'B c', "str", 1.5]), nl.
[a,'B c',"str",1.5]
true.

?- write_term([1, 2, 3, 4], [max_depth(3)]), nl.
[1,2|...]
true.

?- write_term(1 + 2 * 3, [ignore_ops(true)]), nl.
+(1,*(2,3))
true.

?- portray_clause(frame(101, 4, cachelib,
   'Unknown', 0x2a10)).
frame(101, 4, cachelib, 'Unknown', 10768).
true.

?- portray_clause((a :- b, c ; d)).
a :-
    (   b,
        c
    ;   d
    ).
true.
```

```{.prolog .query}
?- T = f(X, Y, X), numbervars(T, 0, End),
   print(T), nl.
f(A,B,A)
T = f(A, B, A),
X = A,
Y = B,
End = 2.

?- T = f(X, Y), numbervars(T, 0, _),
   write_canonical(T), nl.
f('$VAR'(0),'$VAR'(1))
T = f(A, B),
X = A,
Y = B.
```

## 8.4 Term Inspection

```{.prolog .query}
?- functor(frame(109, 0, dbclient, 'Copy', 26),
   N, A).
N = frame,
A = 5.

?- functor(T, frame, 5).
T = frame(_, _, _, _, _).

?- functor(ntdll, N, A).
N = ntdll,
A = 0.

?- functor([a], N, A).
N = '[|]',
A = 2.
```

```{.prolog .query}
?- arg(3, frame(109, 0, dbclient, 'Copy', 26), X).
X = dbclient.

?- arg(N, frame(109, 0, dbclient, 'Copy', 26),
   dbclient).
N = 3 ;
false.

?- arg(N, f(a, b), X).
N = 1,
X = a ;
N = 2,
X = b.

?- arg(6, frame(109, 0, dbclient, 'Copy', 26), X).
false.
```

```{.prolog .query}
?- frame(109, 0, dbclient, 'Copy', 26) =.. L.
L = [frame, 109, 0, dbclient, 'Copy', 26].

?- T =.. [frame, 109, 0].
T = frame(109, 0).

?- ntdll =.. L.
L = [ntdll].

?- T =.. [foo].
T = foo.
```

```{.prolog .query}
?- X = f(a, b), setarg(1, X, c).
X = f(c, b).

?- X = f(a, b), copy_term(X, Y), setarg(1, Y, z).
X = Y, Y = f(z, b).
```

```{.prolog .program}
% frame_field(Name, Index): argument Index of a
% frame/5 term holds the field Name.
frame_field(tid, 1).
frame_field(number, 2).
frame_field(module, 3).
frame_field(function, 4).
frame_field(offset, 5).

% field_of(Frame, Name, Value): Value is the field
% Name of the frame/5 term Frame.
field_of(Frame, Name, Value) :-
    functor(Frame, frame, 5),
    frame_field(Name, Index),
    arg(Index, Frame, Value).
```

```{.prolog .query}
?- field_of(frame(109, 0, dbclient, 'Copy', 26),
   module, M).
M = dbclient.

?- field_of(frame(109, 0, dbclient, 'Copy', 26),
   Name, 26).
Name = offset.

?- field_of(frame(109, 0, dbclient, 'Copy', 26),
   Name, V).
Name = tid,
V = 109 ;
Name = number,
V = 0 ;
Name = module,
V = dbclient ;
Name = function,
V = 'Copy' ;
Name = offset,
V = 26.
```

## 8.5 Diagnostic Use

```{.prolog .program}
:- [dump1].

% symbol_parts(Symbol, Module, Function, Offset):
% Symbol is the atom Module!Function+0xOffset, or
% Module+0xOffset for a frame without a symbol.
symbol_parts(Symbol, Module, Function, Offset) :-
    (   sub_atom(Symbol, B, _, A, '!')
    ->  sub_atom(Symbol, 0, B, _, Module),
        sub_atom(Symbol, _, A, 0, Rest),
        name_offset(Rest, Function, Offset)
    ;   name_offset(Symbol, Module, Offset),
        Function = 'Unknown'
    ).

% name_offset(Text, Name, Offset): Text is
% Name+0xOffset, or Name alone with Offset 0.
name_offset(Text, Name, Offset) :-
    (   sub_atom(Text, B, _, A, '+0x')
    ->  sub_atom(Text, 0, B, _, Name),
        sub_atom(Text, _, A, 0, Hex),
        atom_concat('0x', Hex, HexAtom),
        atom_number(HexAtom, Offset)
    ;   Name = Text,
        Offset = 0
    ).
```

```{.prolog .query}
?- symbol_parts('dbclient!Buffer::Copy+0x1a',
   M, F, O).
M = dbclient,
F = 'Buffer::Copy',
O = 26.

?- symbol_parts('ucrtbase!thread_start<...>+0x42',
   M, F, O).
M = ucrtbase,
F = 'thread_start<...>',
O = 66.

?- symbol_parts('cachelib+0x2a10', M, F, O).
M = cachelib,
F = 'Unknown',
O = 10768.

?- symbol_parts('appserver!wmain', M, F, O).
M = appserver,
F = wmain,
O = 0.
```

```{.prolog .program}
% frame_symbol(Frame, Symbol): Symbol is the
% debugger's text for the frame/5 term Frame.
frame_symbol(frame(_, _, M, F, O), Symbol) :-
    (   F == 'Unknown'
    ->  format(atom(Symbol), "~a+0x~16r", [M, O])
    ;   format(atom(Symbol), "~a!~a+0x~16r",
               [M, F, O])
    ).

% print_frame(TID, N): print frame N of TID as the
% debugger would, with its number.
print_frame(TID, N) :-
    frame(TID, N, M, F, O),
    frame_symbol(frame(TID, N, M, F, O), Symbol),
    format("~`0t~d~2| ~a~n", [N, Symbol]).
```

```{.prolog .query}
?- frame(101, 4, M, F, O),
   frame_symbol(frame(101, 4, M, F, O), S).
M = cachelib,
F = 'Unknown',
O = 10768,
S = 'cachelib+0x2a10'.

?- forall(frame(T, N, M, F, O),
   ( frame_symbol(frame(T, N, M, F, O), S),
     symbol_parts(S, M, F, O) )).
true.

?- forall(frame(109, N, _, _, _),
   print_frame(109, N)).
00 dbclient!Buffer::Copy+0x1a
01 dbclient!Connection::Receive+0x8c
02 appserver!Session::Fetch+0x44
03 appserver!Worker::Run+0x120
04 ucrtbase!thread_start<...>+0x42
05 kernel32!BaseThreadInitThunk+0x14
06 ntdll!RtlUserThreadStart+0x21
true.
```

```{.prolog .program}
% scoped_name(Function, Scope, Name): Function is
% Scope::Name, split at the last scope operator.
scoped_name(Function, Scope, Name) :-
    once(( sub_atom(Function, B, 2, A, '::'),
           sub_atom(Function, _, A, 0, Name),
           \+ sub_atom(Name, _, _, _, '::')
         )),
    sub_atom(Function, 0, B, _, Scope).
```

```{.prolog .query}
?- scoped_name('Buffer::Copy', S, N).
S = 'Buffer',
N = 'Copy'.

?- scoped_name('a::b::c', S, N).
S = 'a::b',
N = c.

?- scoped_name(wmain, S, N).
false.

?- frame(T, 0, _, F, _),
   scoped_name(F, Class, Method).
T = 102,
F = 'Table::Find',
Class = 'Table',
Method = 'Find' ;
T = 107,
F = 'Node::Visit',
Class = 'Node',
Method = 'Visit' ;
T = 109,
F = 'Buffer::Copy',
Class = 'Buffer',
Method = 'Copy'.
```

```{.prolog .program}
% unknown_frame(TID, N, Module): frame N of TID is
% in Module and has no resolved function.
unknown_frame(TID, N, Module) :-
    frame(TID, N, Module, 'Unknown', _).
```

```{.prolog .query}
?- unknown_frame(T, N, M).
T = 101,
N = 4,
M = cachelib.

?- unknown_frame(T, N, M),
   module_info(M, symbols, S).
T = 101,
N = 4,
M = cachelib,
S = none ;
false.

?- forall(unknown_frame(_, _, M),
   module_info(M, symbols, none)).
true.

?- frame(_, _, M, F, _),
   module_info(M, symbols, none), F \== 'Unknown'.
false.
```

```{.prolog .query}
?- frame(T, N, dbclient, F, O),
   format("~d/~d ~a+0x~16r~n", [T, N, F, O]),
   fail.
103/4 Connection::Send+0x58
104/5 Connection::OnReply+0x1f
104/6 Reader::Loop+0xa4
109/0 Buffer::Copy+0x1a
109/1 Connection::Receive+0x8c
false.
```

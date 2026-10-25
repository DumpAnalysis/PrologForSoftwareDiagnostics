# Chapter 6. Arithmetic

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/06-arithmetic.md`.

## 6.1 Evaluation

```{.prolog .query}
?- X = 1 + 2.
X = 1+2.

?- X is 1 + 2.
X = 3.

?- 3 is 1 + 2.
true.

?- 1 + 2 = 3.
false.
```

```{.prolog .query}
?- X is Y + 1.
ERROR: Arguments are not sufficiently instantiated
...

?- X is foo + 1.
ERROR: Arithmetic: `foo/0' is not a function
...

?- X is 1 / 0.
ERROR: Arithmetic: evaluation error: <...>
...
```

```{.prolog .query}
?- succ(X, 4).
X = 3.

?- plus(1, Y, 3).
Y = 2.

?- plus(1, 2, Z).
Z = 3.
```

## 6.2 Comparison

```{.prolog .query}
?- 1 + 2 =:= 3.
true.

?- 2 =< 2, 3 >= 3, 2 =\= 3.
true.

?- 2 < 3.0.
true.

?- 1 =:= 1.0.
true.

?- 1 == 1.0.
false.
```

```{.prolog .query}
?- 1.0 @< 1.
true.

?- 1.0 < 1.
false.

?- '10' @< '9'.
true.

?- a < 1.
ERROR: Arithmetic: `a/0' is not a function
...
```

## 6.3 Integers and Floats

```{.prolog .query}
?- X is 2 ** 64.
X = 18446744073709551616.

?- X is 10 / 4.
X = 2.5.

?- X is 10 / 5.
X = 2.

?- X is 1 + 2.0.
X = 3.0.
```

```{.prolog .query}
?- X is -7 // 2, Y is -7 div 2.
X = -3,
Y = -4.

?- X is -7 mod 2, Y is -7 rem 2.
X = 1,
Y = -1.
```

```{.prolog .query}
?- X is abs(-3), Y is sign(-3), Z is sign(0).
X = 3,
Y = -1,
Z = 0.

?- X is min(2, 3.0), Y is max(2, 3.0).
X = 2,
Y = 3.0.

?- X is gcd(12, 18).
X = 6.

?- X is msb(1024), Y is msb(0x7ffb_8d10_31aa).
X = 10,
Y = 46.

?- X is 2 ** 10, Y is 2 ^ 100.
X = 1024,
Y = 1267650600228229401496703205376.

?- X is 2 ** 0.5.
X = 1.4142135623730951.
```

```{.prolog .query}
?- X is float(3), Y is sqrt(16).
X = 3.0,
Y = 4.0.

?- X is integer(2.5), Y is truncate(2.5).
X = 3,
Y = 2.

?- X is round(-2.5), Y is ceiling(2.1).
X = -3,
Y = 3.

?- Z is floor(-2.1).
Z = -3.
```

```{.prolog .query}
?- X is 0.1 + 0.2.
X = 0.30000000000000004.

?- 0.1 + 0.2 =:= 0.3.
false.
```

## 6.4 Bits

```{.prolog .query}
?- X is 0xff /\ 0x0f, Y is 0xf0 \/ 0x0f.
X = 15,
Y = 255.

?- X is 0xff xor 0x0f, Y is \ 0.
X = 240,
Y = -1.

?- X is 1 << 12.
X = 4096.

?- X is 0x7ffb_8d10_31aa /\ 0xfff.
X = 426.

?- X is 0x7ffb_8d10_31aa /\ \ 0xfff.
X = 140718380167168.

?- X is (0x7ffb_8d10_31aa >> 12) << 12.
X = 140718380167168.
```

## 6.5 Generating Integers

```{.prolog .query}
?- between(1, 3, X).
X = 1 ;
X = 2 ;
X = 3.

?- between(1, 3, 2).
true.

?- between(1, 3, 5).
false.

?- between(1, inf, X).
X = 1 ;
X = 2 ;
X = 3 ;
...
```

```{.prolog .query}
?- between(1, 4, N), S is N * N,
   write(S), nl, fail.
1
4
9
16
false.
```

```{.prolog .program}
% sum_acc(Ns, Acc, Sum): Sum is Acc plus the sum
% of the numbers in Ns.
sum_acc([], Sum, Sum).
sum_acc([N | Ns], Acc0, Sum) :-
    Acc is Acc0 + N,
    sum_acc(Ns, Acc, Sum).
```

```{.prolog .query}
?- sum_acc([120, 40, 8450, 1230], 0, Sum).
Sum = 9840.

?- sum_acc([], 0, Sum).
Sum = 0.
```

## 6.6 Formatted Output

```{.prolog .query}
?- format("~w and ~a~n", [f(X), 'Buffer::Copy']).
f(_<...>) and Buffer::Copy
true.

?- format("~q ~w~n",
   ['Buffer::Copy', 'Buffer::Copy']).
'Buffer::Copy' Buffer::Copy
true.

?- format("~c~c ~s ~*c~n",
   [0'O, 0'K, "done", 3, 0'-]).
OK done ---
true.

?- format("~a~n", [f(x)]).
ERROR: Illegal argument to format sequence <...>
...
```

```{.prolog .query}
?- format("~d ~D~n", [12040, 12040]).
12040 12,040
true.

?- format("~3d s~n", [9680]).
9.680 s
true.

?- format("~f ~3f ~0f ~3f~n", [2.5, 2.5, 2.5, 2]).
2.500000 2.500 2 2.000
true.

?- format("~e ~4e ~g~n",
   [12040.0, 12345.678, 0.5]).
1.204000e+04 1.2346e+04 0.5
true.

?- format("~d~n", [1.5]).
ERROR: Illegal argument to format sequence ~d: 1.5
...
```

```{.prolog .query}
?- format("~16r ~16R ~8r ~2r~n",
   [255, 255, 255, 5]).
ff FF 377 101
true.

?- format("~16r~n", [0x7ffb_8d10_31aa]).
7ffb8d1031aa
true.

?- format("~16r~n", [0xc0000005]).
c0000005
true.
```

```{.prolog .query}
?- format("~`0t~16r~16|~n", [0x7ffb_8d10_31aa]).
00007ffb8d1031aa
true.

?- format("0x~`0t~16r~18|~n", [0x7ffb_8d10_31aa]).
0x00007ffb8d1031aa
true.

?- format("~`0t~16r~8|~n", [0x18]).
00000018
true.
```

```{.prolog .program}
% print_address(Addr): print a 64-bit address in
% the debugger's hhhhhhhh`llllllll notation.
print_address(Addr) :-
    High is Addr >> 32,
    Low is Addr /\ 0xffff_ffff,
    format("~`0t~16r~8|`~`0t~16r~9+~n",
           [High, Low]).
```

```{.prolog .query}
?- print_address(0x7ffb_8d10_31aa).
00007ffb`8d1031aa
true.

?- print_address(0x18).
00000000`00000018
true.
```

```{.prolog .query}
?- format("~a~t~12|~t~d~8+~n", [ntdll, 160]).
ntdll            160
true.

?- format("~a~t~12|~t~d~8+~n",
   [reportengine, 9680]).
reportengine    9680
true.
```

## 6.7 Diagnostic Use

```{.prolog .program}
:- [dump1].

% address_module(Addr, Module): Addr lies in the
% address range of Module.
address_module(Addr, Module) :-
    module(Module, Base, Size),
    Base =< Addr,
    Addr < Base + Size.

% print_symbol(Addr): print Addr as module+offset.
print_symbol(Addr) :-
    address_module(Addr, Module),
    module(Module, Base, _),
    Offset is Addr - Base,
    format("~a+0x~16r~n", [Module, Offset]).
```

```{.prolog .query}
?- exception_record(109, Code, Addr),
   address_module(Addr, M).
Code = 3221225477,
Addr = 140718380167594,
M = dbclient ;
false.

?- exception_record(109, Code, Addr),
   format("~16r at ", [Code]), print_symbol(Addr).
c0000005 at dbclient+0x31aa
Code = 3221225477,
Addr = 140718380167594 ;
false.
```

```{.prolog .query}
?- address_module(0x0000_0210_a000_0000, M).
false.

?- address_module(0x18, M).
false.
```

```{.prolog .query}
?- exception_info(109, target, T), T < 0x1_0000,
   format("null + 0x~16r~n", [T]).
null + 0x18
T = 24.
```

```{.prolog .query}
?- exception_record(109, _, A), P is A /\ \ 0xfff,
   O is A /\ 0xfff, format("~16r ~16r~n", [P, O]).
7ffb8d103000 1aa
A = 140718380167594,
P = 140718380167168,
O = 426.

?- module(thirdparty_hook, _, Size),
   Pages is Size // 0x1000.
Size = 73728,
Pages = 18.
```

```{.prolog .query}
?- module(thirdparty_hook, Base, _),
   between(0, 2, I), Page is Base + I * 0x1000,
   print_address(Page), fail.
00007ffb`6f300000
00007ffb`6f301000
00007ffb`6f302000
false.
```

```{.prolog .program}
% cpu_time(TID, Ms): the CPU time of TID in
% milliseconds, user and kernel together.
cpu_time(TID, Ms) :-
    thread_time(TID, User, Kernel),
    Ms is User + Kernel.
```

```{.prolog .query}
?- cpu_time(102, Ms).
Ms = 9680.

?- cpu_time(TID, Ms), Ms > 1000.
TID = 102,
Ms = 9680 ;
TID = 107,
Ms = 4100 ;
false.
```

```{.prolog .program}
% next_thread(TID, Next): Next is the thread with
% the smallest identifier greater than TID.
next_thread(TID, Next) :-
    thread(Next, _),
    Next > TID,
    \+ ( thread(Other, _),
         Other > TID,
         Other < Next
       ).

% cpu_sum_above(TID, Acc, Total): Total is Acc
% plus the CPU time of every thread above TID.
cpu_sum_above(TID, Acc0, Total) :-
    next_thread(TID, Next),
    cpu_time(Next, Ms),
    Acc is Acc0 + Ms,
    cpu_sum_above(Next, Acc, Total).
cpu_sum_above(TID, Total, Total) :-
    \+ next_thread(TID, _).

% total_cpu(Total): the CPU time of all threads.
total_cpu(Total) :-
    cpu_sum_above(0, 0, Total).

% cpu_share(TID, Percent): the CPU time of TID as
% a percentage of the total.
cpu_share(TID, Percent) :-
    cpu_time(TID, Ms),
    total_cpu(Total),
    Percent is 100.0 * Ms / Total.
```

```{.prolog .query}
?- next_thread(0, T).
T = 100 ;
false.

?- next_thread(104, T).
T = 105 ;
false.

?- total_cpu(Total).
Total = 14135 ;
false.

?- cpu_share(102, P).
P = 68.48249027237354 ;
false.

?- cpu_share(108, P).
P = 0.0 ;
false.
```

```{.prolog .program}
% spiking_threshold(Percent): a thread whose share
% of the CPU time is at least Percent is spiking.
spiking_threshold(25).

% spiking_thread(TID): TID has consumed at least
% the threshold share of the process CPU time.
spiking_thread(TID) :-
    cpu_share(TID, Percent),
    spiking_threshold(Threshold),
    Percent >= Threshold.
```

```{.prolog .query}
?- spiking_thread(T).
T = 102 ;
T = 107 ;
false.

?- spiking_thread(100).
false.
```

```{.prolog .program}
% print_cpu_share(TID): one table row for TID.
print_cpu_share(TID) :-
    cpu_time(TID, Ms),
    cpu_share(TID, Percent),
    format("~d~t~6|~t~D~8+ ms~3+~t~1f~8+%~n",
           [TID, Ms, Percent]).
```

```{.prolog .query}
?- print_cpu_share(102).
102      9,680 ms    68.5%
true ;
false.

?- thread(T, _), print_cpu_share(T), fail.
100        160 ms     1.1%
101         20 ms     0.1%
102      9,680 ms    68.5%
103         40 ms     0.3%
104         35 ms     0.2%
105         25 ms     0.2%
106         15 ms     0.1%
107      4,100 ms    29.0%
108          0 ms     0.0%
109         60 ms     0.4%
false.
```

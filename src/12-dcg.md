# Chapter 12. Definite Clause Grammars

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/12-dcg.md`.

## 12.1 Grammar Rules

```{.prolog .program}
:- use_module(library(dcg/basics)).
:- use_module(library(dcg/high_order)).
:- use_module(library(pure_input)).

% method(M): the name of an HTTP method.
method(get) --> "GET".
method(post) --> "POST".

% health_check(M): a request line for the health
% path, with method M.
health_check(M) --> method(M), " /health".
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.

?- string_codes("GET /health", _Cs),
   phrase(health_check(M), _Cs).
M = get.

?- string_codes("GET /report/17", _Cs),
   phrase(health_check(M), _Cs).
false.

?- X = `abc`.
X = [97, 98, 99].

?- catch(phrase(health_check(M), "GET /health"),
         error(E, _), true).
E = type_error(list, "GET /health").
```

```{.prolog .query}
?- phrase(health_check(post), _Cs),
   string_codes(S, _Cs).
S = "POST /health".

?- phrase(health_check(M), _Cs),
   string_codes(S, _Cs).
M = get,
S = "GET /health" ;
M = post,
S = "POST /health".
```

```{.prolog .query}
?- string_codes("GET /health HTTP/1.1", _Cs),
   phrase(health_check(M), _Cs, _Rest),
   string_codes(R, _Rest).
M = get,
R = " HTTP/1.1".
```

## 12.2 The Translation

```{.prolog .query}
?- listing(method//1).
method(get, [71, 69, 84|A], A).
method(post, [80, 79, 83, 84|A], A).

true.

?- listing(health_check//1).
health_check(M, A, B) :-
    method(M, A, C),
    C=[32, 47, 104, 101, 97, 108, 116, 104|B].

true.
```

```{.prolog .program}
% digit_code(D): one code that is a decimal digit.
digit_code(D) --> [D], { code_type(D, digit) }.

% digit_codes(Ds): one or more digit codes.
digit_codes([D | Ds]) -->
    digit_code(D),
    digit_codes(Ds).
digit_codes([D]) -->
    digit_code(D).

% nat(N): a natural number written in decimal.
nat(N) -->
    digit_codes(Ds),
    { number_codes(N, Ds) }.
```

```{.prolog .query}
?- listing(nat//1).
nat(N, A, B) :-
    digit_codes(Ds, A, C),
    number_codes(N, Ds),
    B=C.

true.

?- string_codes("123", _Cs), phrase(nat(N), _Cs).
N = 123 ;
false.

?- string_codes("123abc", _Cs),
   phrase(nat(N), _Cs, _R), string_codes(R, _R).
N = 123,
R = "abc" ;
N = 12,
R = "3abc" ;
N = 1,
R = "23abc".
```

```{.prolog .program}
% digit_codes_det(Ds): the longest run of one or
% more digit codes, deterministically.
digit_codes_det([D | Ds]) -->
    digit_code(D),
    (   digit_codes_det(Ds)
    ->  []
    ;   { Ds = [] }
    ).

% nat_det(N): as nat/1, deterministically.
nat_det(N) -->
    digit_codes_det(Ds),
    { number_codes(N, Ds) }.
```

```{.prolog .query}
?- string_codes("123abc", _Cs),
   phrase(nat_det(N), _Cs, _R),
   string_codes(R, _R).
N = 123,
R = "abc".

?- string_codes("abc", _Cs),
   phrase(nat_det(N), _Cs, _R).
false.

?- string_codes("42 ms", _Cs),
   phrase((nat_det(N), " ms"), _Cs).
N = 42.
```

```{.prolog .program}
% at_digit: the next code is a digit, which is not
% consumed.
at_digit, [C] --> [C], { code_type(C, digit) }.
```

```{.prolog .query}
?- listing(at_digit//0).
at_digit([A|B], C) :-
    code_type(A, digit),
    D=B,
    C=[A|D].

true.

?- string_codes("42", _Cs),
   phrase((at_digit, nat_det(N)), _Cs).
N = 42.

?- string_codes("x42", _Cs),
   phrase((at_digit, nat_det(N)), _Cs).
false.

?- string_codes("42", _Cs),
   phrase(call(nat_det, N), _Cs).
N = 42.
```

## 12.3 The Basics Library

```{.prolog .query}
?- string_codes("  42", _Cs),
   phrase((blanks, integer(N)), _Cs).
N = 42.

?- string_codes("-7", _Cs),
   phrase(integer(X), _Cs).
X = -7.

?- string_codes("0101", _Cs),
   phrase(integer(X), _Cs).
X = 101.

?- string_codes("1.234", _Cs),
   phrase(number(X), _Cs).
X = 1.234.

?- string_codes("1f8000", _Cs),
   phrase(xinteger(X), _Cs).
X = 2064384.

?- string_codes("x", _Cs),
   phrase(digits(D), _Cs, _R),
   string_codes(R, _R).
D = [],
R = "x".
```

```{.prolog .query}
?- string_codes("a1 b2", _Cs),
   phrase((nonblanks(A), white, nonblanks(B)),
          _Cs),
   string_codes(SA, A), string_codes(SB, B).
A = [97, 49],
B = [98, 50],
SA = "a1",
SB = "b2".

?- string_codes("abc,def", _Cs),
   phrase(string_without(",", L), _Cs, _R),
   string_codes(S, L), string_codes(R, _R).
L = [97, 98, 99],
S = "abc",
R = ",def".

?- string_codes("abc def", _Cs),
   phrase((string(L), " def"), _Cs),
   string_codes(S, L).
L = [97, 98, 99],
S = "abc" ;
false.

?- string_codes("\n x", _Cs),
   phrase((whites, "x"), _Cs).
false.

?- string_codes("\n x", _Cs),
   phrase((blanks, "x"), _Cs).
true.

?- string_codes("abc", _Cs),
   phrase((string_without("\n", L), eol), _Cs),
   string_codes(S, L).
L = [97, 98, 99],
S = "abc".
```

## 12.4 Sequences

```{.prolog .query}
?- string_codes("1,2,3", _Cs),
   phrase(sequence(integer, ",", L), _Cs).
L = [1, 2, 3].

?- string_codes("[1,2,3]", _Cs),
   phrase(sequence("[", integer, ",", "]", L),
          _Cs).
L = [1, 2, 3].

?- phrase(sequence(integer, ",", [1, 2, 3]), _Cs),
   string_codes(S, _Cs).
S = "1,2,3".

?- string_codes("12ab", _Cs),
   phrase(sequence(digit, L), _Cs, _R),
   string_codes(R, _R).
L = [49, 50],
R = "ab" ;
L = [49],
R = "2ab" ;
L = [],
R = "12ab".
```

## 12.5 A Frame Line

```{.prolog .program}
% addr64(A): a 64-bit address as the debugger
% prints it, two groups of hex digits around `.
addr64(A) -->
    xinteger(Hi), "`", xinteger(Lo),
    { A is Hi << 32 \/ Lo }.

% symbol(M, F, O): the symbol M!F+0xO, or M+0xO
% with F = 'Unknown'.
symbol(M, F, O) -->
    string_without("!+", MC),
    { atom_codes(M, MC) },
    (   "!"
    ->  string_without("+", FC),
        { atom_codes(F, FC) }
    ;   { F = 'Unknown' }
    ),
    "+0x",
    xinteger(O).

% frame_line(TID, Frame): one line of k output for
% thread TID, as a frame/5 term.
frame_line(TID, frame(TID, N, M, F, O)) -->
    xinteger(N), blank,
    addr64(_), blank,
    addr64(_), blank,
    symbol(M, F, O).
```

```{.prolog .query}
?- string_codes("00007ffb`b0b2a0b0", _Cs),
   phrase(addr64(A), _Cs), format("~16r~n", [A]).
7ffbb0b2a0b0
A = 140718978015408.

?- string_codes("dbclient!Buffer::Copy+0x1a",
   _Cs), phrase(symbol(M, F, O), _Cs).
M = dbclient,
F = 'Buffer::Copy',
O = 26.

?- string_codes("cachelib+0x2a10", _Cs),
   phrase(symbol(M, F, O), _Cs).
M = cachelib,
F = 'Unknown',
O = 10768.

?- string_codes("ucrtbase!thread_start<...>+0x42",
   _Cs), phrase(symbol(M, F, O), _Cs).
M = ucrtbase,
F = 'thread_start<...>',
O = 66.
```

```{.prolog .program}
% k_line(N, Line): the Nth line of an abridged k
% output, as a string.
k_line(0,
       "00 00000000`0014f5a8 00007ffb`b0b2a0b0 \c
        kernelbase!SleepEx+0x9e").
k_line(1,
       "01 00000000`0014f5b0 00007ff6`1d10a3a0 \c
        appserver!MainLoop+0x1b2").
k_line(2,
       "02 00000000`0014f620 00007ffb`7a002a10 \c
        cachelib+0x2a10").
```

```{.prolog .query}
?- k_line(0, _L), string_codes(_L, _Cs),
   phrase(frame_line(100, F), _Cs).
F = frame(100, 0, kernelbase, 'SleepEx', 158).

?- forall(k_line(_, L),
          ( string_codes(L, Cs),
            phrase(frame_line(100, F), Cs),
            print(F), nl
          )).
frame(100,0,kernelbase,'SleepEx',158)
frame(100,1,appserver,'MainLoop',434)
frame(100,2,cachelib,'Unknown',10768)
true.
```

```{.prolog .program}
% symbol_text(M, F, O): the debugger's text for a
% symbol, for output.
symbol_text(M, F, O) -->
    atom(M),
    (   { F == 'Unknown' }
    ->  []
    ;   "!", atom(F)
    ),
    "+0x", xinteger(O).

% frame_text(Frame): a frame as a numbered line
% without its address columns, for output.
frame_text(frame(_, N, M, F, O)) -->
    { format(codes(NC), "~`0t~16r~2|", [N]) },
    NC, " ",
    symbol_text(M, F, O).
```

```{.prolog .query}
?- phrase(symbol_text(cachelib, 'Unknown', 10768),
   _Cs), string_codes(S, _Cs).
S = "cachelib+0x2a10".

?- k_line(1, _L), string_codes(_L, _Cs),
   phrase(frame_line(100, F), _Cs),
   phrase(frame_text(F), _Out),
   string_codes(S, _Out).
F = frame(100, 1, appserver, 'MainLoop', 434),
S = "01 appserver!MainLoop+0x1b2".
```

## 12.6 A Log Line

```{.prolog .program}
% date(date(Y, M, D)): a date as YYYY-MM-DD.
date(date(Y, M, D)) -->
    integer(Y), "-", integer(M), "-", integer(D).

% time_of_day(T): HH:MM:SS.mmm as seconds since
% midnight.
time_of_day(T) -->
    integer(H), ":", integer(Mi), ":", number(S),
    { T is H * 3600 + Mi * 60 + S }.

% log_line(N, Msg): one line of the log, as the
% msg/6 term with ordinal number N.
log_line(N, Msg) -->
    date(_), " ",
    time_of_day(Time), " [",
    integer(PID), ":", integer(TID), "] ",
    string_without(":", CC), ": ",
    string_without("\n", TC),
    { atom_codes(Comp, CC),
      string_codes(Text, TC),
      Msg = msg(N, Time, PID, TID, Comp, Text)
    }.

% sample_msg(Line): one log line as a string.
sample_msg("2026-10-03 12:00:01.234 [4120:0101] \c
            appserver: Request 1 received").
```

```{.prolog .query}
?- string_codes("12:00:01.234", _Cs),
   phrase(time_of_day(T), _Cs).
T = 43201.234.

?- string_codes("2026-10-03", _Cs),
   phrase(date(D), _Cs).
D = date(2026, 10, 3).

?- sample_msg(_S), string_codes(_S, _Cs),
   phrase(log_line(1, msg(N, T, P, TID, C, Text)),
          _Cs).
N = 1,
T = 43201.234,
P = 4120,
TID = 101,
C = appserver,
Text = "Request 1 received".
```

## 12.7 Grammars over Files

```{.prolog .program}
% log_lines(N, Msgs): the msg/6 terms of the lines
% from here to the end of input, numbered from N.
log_lines(N, Msgs) -->
    (   eos
    ->  { Msgs = [] }
    ;   log_line(N, Msg), "\n",
        { Msgs = [Msg | Msgs1],
          N1 is N + 1
        },
        log_lines(N1, Msgs1)
    ).
```

```{.prolog .program}
% sample_log_line(Line): a line of the sample log.
sample_log_line(
    "2026-10-03 12:00:01.234 [4120:0100] \c
     appserver: Service starting").
sample_log_line(
    "2026-10-03 12:00:01.235 [4120:0101] \c
     appserver: Worker 101 ready").
sample_log_line(
    "2026-10-03 12:00:02.000 [4120:0101] \c
     dbclient: Query start: 17").
sample_log_line(
    "2026-10-03 12:00:02.044 [4120:0101] \c
     dbclient: Query end: 44 ms").
sample_log_line(
    "2026-10-03 12:00:07.002 [4120:0100] \c
     appserver: Error: no worker").
sample_log_line(
    "2026-10-03 12:00:09.301 [4120:0101] \c
     appserver: Request 5 done").

% write_sample_log(File): write the sample log to
% File, one line per sample_log_line/1 fact.
write_sample_log(File) :-
    setup_call_cleanup(
        open(File, write, Out),
        forall(sample_log_line(Line),
               format(Out, "~s~n", [Line])),
        close(Out)).
```

```text
2026-10-03 12:00:01.234 [4120:0100] appserver: Service starting
2026-10-03 12:00:01.235 [4120:0101] appserver: Worker 101 ready
2026-10-03 12:00:02.000 [4120:0101] dbclient: Query start: 17
2026-10-03 12:00:02.044 [4120:0101] dbclient: Query end: 44 ms
2026-10-03 12:00:07.002 [4120:0100] appserver: Error: no worker
2026-10-03 12:00:09.301 [4120:0101] appserver: Request 5 done
```

```{.prolog .query}
?- write_sample_log('sample.log').
true.

?- phrase_from_file(log_lines(1, _Msgs),
                    'sample.log'),
   length(_Msgs, N).
N = 6.

?- phrase_from_file(log_lines(1, _Msgs),
                    'sample.log'),
   nth1(5, _Msgs, msg(N, T, P, TID, C, Text)).
N = 5,
T = 43207.002,
P = 4120,
TID = 100,
C = appserver,
Text = "Error: no worker".
```

```{.prolog .program}
% msg(N, Time, PID, TID, Component, Text): the
% schema relation, filled from a parsed log.
:- dynamic msg/6.

% load_log(File): parse File and assert its
% messages as msg/6 facts.
load_log(File) :-
    phrase_from_file(log_lines(1, Msgs), File),
    maplist(assertz, Msgs).
```

```{.prolog .query}
?- load_log('sample.log').
true.

?- msg(N, _, _, 101, C, Text).
N = 2,
C = appserver,
Text = "Worker 101 ready" ;
N = 3,
C = dbclient,
Text = "Query start: 17" ;
N = 4,
C = dbclient,
Text = "Query end: 44 ms" ;
N = 6,
C = appserver,
Text = "Request 5 done".

?- aggregate_all(count, msg(_, _, _, _, _, _), N).
N = 6.
```

## 12.8 Diagnostic Use

```text
.  0  Id: 1018.64 Suspend: 1 Teb: 00000000`0025d000 Unfrozen
 # Child-SP          RetAddr           Call Site
00 00000000`0014f5a8 00007ffb`b0b2a0b0 kernelbase!SleepEx+0x9e
01 00000000`0014f5b0 00007ff6`1d10a3a0 appserver!MainLoop+0x1b2
   1  Id: 1018.65 Suspend: 1 Teb: 00000000`00260000 Unfrozen
 # Child-SP          RetAddr           Call Site
00 00000000`0024f8c8 00007ffb`b0b2a0b0 kernelbase!SleepEx+0x9e
01 00000000`0024f8d0 00007ffb`7a002a10 cachelib+0x2a10
```

```{.prolog .program}
% thread_header(TID): the line that introduces a
% thread in ~*k output; TID is read from Id:.
thread_header(TID) -->
    [_], blanks, integer(_), blanks,
    "Id: ", xinteger(_), ".", xinteger(TID),
    string_without("\n", _), "\n".

% column_header: the # Child-SP ... line.
column_header -->
    blanks, "#", string_without("\n", _), "\n".

% frame_lines(TID, Frames): the frame lines that
% follow, each a frame/5 term of thread TID.
frame_lines(TID, Frames) -->
    (   frame_line(TID, F), "\n"
    ->  { Frames = [F | Fs] },
        frame_lines(TID, Fs)
    ;   { Frames = [] }
    ).

% thread_block(Frames): one thread's header and
% frames.
thread_block(Frames) -->
    thread_header(TID),
    column_header,
    frame_lines(TID, Frames).

% k_output(Frames): the frames of every thread in
% the output, in order.
k_output(Frames) -->
    (   eos
    ->  { Frames = [] }
    ;   thread_block(Fs),
        k_output(Rest),
        { append(Fs, Rest, Frames) }
    ).
```

```{.prolog .program}
% sample_k_line(Line): a line of the abridged ~*k
% output.
sample_k_line(
    ".  0  Id: 1018.64 Suspend: 1 \c
     Teb: 00000000`0025d000 Unfrozen").
sample_k_line(
    " # Child-SP          RetAddr           \c
     Call Site").
sample_k_line(
    "00 00000000`0014f5a8 00007ffb`b0b2a0b0 \c
     kernelbase!SleepEx+0x9e").
sample_k_line(
    "01 00000000`0014f5b0 00007ff6`1d10a3a0 \c
     appserver!MainLoop+0x1b2").
sample_k_line(
    "   1  Id: 1018.65 Suspend: 1 \c
     Teb: 00000000`00260000 Unfrozen").
sample_k_line(
    " # Child-SP          RetAddr           \c
     Call Site").
sample_k_line(
    "00 00000000`0024f8c8 00007ffb`b0b2a0b0 \c
     kernelbase!SleepEx+0x9e").
sample_k_line(
    "01 00000000`0024f8d0 00007ffb`7a002a10 \c
     cachelib+0x2a10").

% write_sample_k(File): write the sample output.
write_sample_k(File) :-
    setup_call_cleanup(
        open(File, write, Out),
        forall(sample_k_line(Line),
               format(Out, "~s~n", [Line])),
        close(Out)).

% frame(TID, N, Module, Function, Offset): the
% schema relation, filled from parsed k output.
:- dynamic frame/5.

% load_k(File): parse the ~*k output in File and
% assert its frames.
load_k(File) :-
    phrase_from_file(k_output(Frames), File),
    maplist(assertz, Frames).

% print_frames(TID): the stack trace of TID as
% numbered lines, from the parsed frames.
print_frames(TID) :-
    forall(frame(TID, N, M, F, O),
           ( Frame = frame(TID, N, M, F, O),
             phrase(frame_text(Frame), Codes),
             format("~s~n", [Codes])
           )).
```

```{.prolog .query}
?- write_sample_k('k.txt').
true.

?- phrase_from_file(k_output(_Fs), 'k.txt'),
   length(_Fs, N).
N = 4.

?- load_k('k.txt').
true.

?- frame(T, N, M, F, O).
T = 100,
N = 0,
M = kernelbase,
F = 'SleepEx',
O = 158 ;
T = 100,
N = 1,
M = appserver,
F = 'MainLoop',
O = 434 ;
T = 101,
N = 0,
M = kernelbase,
F = 'SleepEx',
O = 158 ;
T = 101,
N = 1,
M = cachelib,
F = 'Unknown',
O = 10768.
```

```{.prolog .query}
?- frame(T, N, M, 'Unknown', _).
T = 101,
N = 1,
M = cachelib.

?- print_frames(100).
00 kernelbase!SleepEx+0x9e
01 appserver!MainLoop+0x1b2
true.
```

```{.prolog .program}
% error_prefix: the text begins with "Error:".
error_prefix --> "Error:".

% error_message(N): message N is an Error Message:
% its text begins with the error prefix.
error_message(N) :-
    msg(N, _, _, _, _, Text),
    string_codes(Text, Codes),
    phrase(error_prefix, Codes, _).
```

```{.prolog .query}
?- error_message(N), msg(N, T, _, TID, C, Text).
N = 5,
T = 43207.002,
TID = 100,
C = appserver,
Text = "Error: no worker" ;
false.
```

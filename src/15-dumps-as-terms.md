# Chapter 15. Memory Dumps as Knowledge Bases

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/15-dumps-as-terms.md`.

## 15.1 What a Dump Contains and What a Debugger Derives

## 15.2 The Schema

```{.prolog .program}
:- [dump1].
```

```{.prolog .query}
?- critical_section(A, _, WaiterCount, _),
   aggregate_all(count,
      waits_for(_, critical_section, A), Waiting).
A = 140695026507968,
WaiterCount = Waiting, Waiting = 2 ;
A = 140695026508096,
WaiterCount = Waiting, Waiting = 1 ;
A = 140695026508224,
WaiterCount = Waiting, Waiting = 0.
```

```{.prolog .program}
% schema(Relation, Fields): Relation is a relation
% of the dump schema; Fields names its arguments
% in order.
schema(process/2, [pid, name]).
schema(module/3, [name, base, size]).
schema(module_info/3, [name, key, value]).
schema(thread/2, [tid, pid]).
schema(thread_time/3, [tid, user_ms, kernel_ms]).
schema(thread_state/2, [tid, state]).
schema(frame/5,
       [tid, number, module, function, offset]).
schema(exception_record/3, [tid, code, address]).
schema(exception_info/3, [tid, key, value]).
schema(critical_section/4,
       [address, owner, waiters, recursion]).
schema(waits_for/3, [tid, kind, address]).
schema(handle_count/3, [pid, type, count]).
schema(heap/4,
       [address, reserved, committed, free]).
schema(last_error/2, [tid, code]).
schema(hooked/3, [function, module, hooker]).

% field(Fact, Name, Value): Value is the argument
% of Fact that the schema names Name.
field(Fact, Name, Value) :-
    functor(Fact, F, A),
    schema(F/A, Fields),
    nth1(Index, Fields, Name),
    arg(Index, Fact, Value).

% fact_count(Relation, Count): Count facts of the
% schema relation Relation are loaded.
fact_count(F/A, Count) :-
    schema(F/A, _),
    functor(Goal, F, A),
    aggregate_all(count, Goal, Count).
```

```{.prolog .query}
?- field(critical_section(1, 2, 3, 4), N, V).
N = address,
V = 1 ;
N = owner,
V = 2 ;
N = waiters,
V = 3 ;
N = recursion,
V = 4.

?- fact_count(frame/5, N).
N = 78.

?- forall(fact_count(R, C),
   format("~w~t~20|~t~d~4+~n", [R, C])).
process/2              1
module/3              10
module_info/3         20
thread/2              10
thread_time/3         10
thread_state/2        10
frame/5               78
exception_record/3     1
exception_info/3       2
critical_section/4     3
waits_for/3            3
handle_count/3         6
heap/4                 3
last_error/2           6
hooked/3               2
true.

?- aggregate_all(sum(C), fact_count(_, C), Total).
Total = 165.
```

## 15.3 From Debugger Output to Facts

```text
 # Child-SP          RetAddr               Call Site
00 0000004a`2b3ff8c8 00007ffb`b0b2a09e
   ntdll!NtDelayExecution+0x14
01 0000004a`2b3ff8d0 00007ff6`1d10503a
   KERNELBASE!SleepEx+0x9e
02 0000004a`2b3ff970 00007ffb`b1c14014
   appserver!Housekeeping::Run+0x3a
03 0000004a`2b3ff9b0 00007ffb`b2a52651
   KERNEL32!BaseThreadInitThunk+0x14
04 0000004a`2b3ff9e0 00000000`00000000
   ntdll!RtlUserThreadStart+0x21
```

```{.prolog .program}
:- use_module(library(dcg/basics)).

% k_line(TID, Frame)//: one frame line of kn
% output for thread TID, as a frame/5 term.
k_line(TID, frame(TID, N, M, F, O)) -->
    xinteger(N), blanks,
    address(_ChildSP), blanks,
    address(_RetAddr), blanks,
    symbol(M, F, O), eos.

% address(A)//: a 64-bit address, two hexadecimal
% halves separated by a backquote.
address(A) -->
    xinteger(Hi), "`", xinteger(Lo),
    { A is Hi << 32 \/ Lo }.

% symbol(M, F, O)//: module!function+0xoffset, or
% module+0xoffset for a frame without a symbol.
symbol(M, F, O) -->
    string_without("!+", MC),
    { atom_codes(M0, MC), downcase_atom(M0, M) },
    (   "!"
    ->  string_without("+", FC),
        { atom_codes(F, FC) }
    ;   { F = 'Unknown' }
    ),
    "+0x", xinteger(O).
```

```{.prolog .program}
% k_columns(LineNo, N, ChildSP, RetAddr,
% CallSite): the columns of log line LineNo of
% dump1.log, a frame line of thread 108.
k_columns(212, '00', '0000004a`2b3ff8c8',
          '00007ffb`b0b2a09e',
          'ntdll!NtDelayExecution+0x14').
k_columns(213, '01', '0000004a`2b3ff8d0',
          '00007ff6`1d10503a',
          'KERNELBASE!SleepEx+0x9e').
k_columns(214, '02', '0000004a`2b3ff970',
          '00007ffb`b1c14014',
          'appserver!Housekeeping::Run+0x3a').
k_columns(215, '03', '0000004a`2b3ff9b0',
          '00007ffb`b2a52651',
          'KERNEL32!BaseThreadInitThunk+0x14').
k_columns(216, '04', '0000004a`2b3ff9e0',
          '00000000`00000000',
          'ntdll!RtlUserThreadStart+0x21').

% log_line(Log, LineNo, Text): line LineNo of the
% log file Log is Text. dump1.log holds the frame
% lines of thread 108 as the debugger printed
% them; bad.log holds the same lines with the
% offset of line 214 removed, a form the grammar
% does not accept, for the check at the end of
% this section.
log_line('dump1.log', LineNo, Text) :-
    k_columns(LineNo, N, SP, Ret, Sym),
    atomic_list_concat([N, SP, Ret, Sym], ' ',
                       Text).
log_line('bad.log', LineNo, Text) :-
    log_line('dump1.log', LineNo, Text0),
    (   LineNo =:= 214
    ->  atom_concat(Text, '+0x3a', Text0)
    ;   Text = Text0
    ).

% parse_k_line(TID, Text, Frame): Frame is the
% frame/5 term for the frame line Text of TID.
parse_k_line(TID, Text, Frame) :-
    atom_codes(Text, Codes),
    phrase(k_line(TID, Frame), Codes).
```

```{.prolog .query}
?- log_line('dump1.log', _, L),
   parse_k_line(108, L, F),
   portray_clause(F), fail.
frame(108, 0, ntdll, 'NtDelayExecution', 20).
frame(108, 1, kernelbase, 'SleepEx', 158).
frame(108, 2, appserver, 'Housekeeping::Run', 58).
frame(108, 3, kernel32, <...>, 20).
frame(108, 4, ntdll, 'RtlUserThreadStart', 33).
false.

?- forall(log_line('dump1.log', _, L),
   ( parse_k_line(108, L, F), call(F) )).
true.
```

```{.prolog .program}
% parse_record(Log, TID, LineNo-Text, Frame):
% Frame is the frame/5 term for the frame line
% Text of TID; a line the grammar rejects raises a
% syntax error located at Log:LineNo.
parse_record(Log, TID, LineNo-Text, Frame) :-
    (   parse_k_line(TID, Text, Frame0)
    ->  Frame = Frame0
    ;   format(atom(Where), "~w:~d: ~w",
               [Log, LineNo, Text]),
        throw(error(syntax_error(k_line),
                    context(parse_record/4,
                            Where)))
    ).

% check_keys(Frames): the (TID, N) keys of Frames
% are distinct; a repeated key raises an error.
check_keys(Frames) :-
    findall(T-N,
            member(frame(T, N, _, _, _), Frames),
            Keys),
    msort(Keys, Sorted),
    (   append(_, [Key, Key | _], Sorted)
    ->  domain_error(unique_frame_key, Key)
    ;   true
    ).

% write_frames(Log, TID, File): parse every frame
% line of TID in Log and write the frame/5 facts
% to File, one per line. Nothing is written until
% every line has parsed and the keys are distinct.
write_frames(Log, TID, File) :-
    findall(LineNo-Text,
            log_line(Log, LineNo, Text),
            Records),
    maplist(parse_record(Log, TID),
            Records, Frames),
    check_keys(Frames),
    setup_call_cleanup(
        open(File, write, S),
        maplist(portray_clause(S), Frames),
        close(S)).
```

```{.prolog .program}
% read_facts(File, Facts): Facts are the terms of
% File, in order.
read_facts(File, Facts) :-
    setup_call_cleanup(
        open(File, read, S),
        read_terms(S, Facts),
        close(S)).

read_terms(S, Facts) :-
    read_term(S, Term, []),
    (   Term == end_of_file
    ->  Facts = []
    ;   Facts = [Term | Rest],
        read_terms(S, Rest)
    ).

% frames_agree(Log, TID, File): File holds one
% fact per frame line of TID in Log, and those
% facts are exactly the frame/5 facts of TID in
% the loaded knowledge base, each side counted
% with repetitions.
frames_agree(Log, TID, File) :-
    aggregate_all(count, log_line(Log, _, _), In),
    read_facts(File, Written),
    length(Written, In),
    findall(frame(TID, N, M, F, O),
            frame(TID, N, M, F, O), Loaded),
    msort(Written, Canonical),
    msort(Loaded, Canonical).
```

```{.prolog .query}
?- write_frames('dump1.log', 108, 'frames108.pl').
true.

?- read_file_to_string('frames108.pl', S, []),
   write(S).
frame(108, 0, ntdll, 'NtDelayExecution', 20).
frame(108, 1, kernelbase, 'SleepEx', 158).
frame(108, 2, appserver, 'Housekeeping::Run', 58).
frame(108, 3, kernel32, <...>, 20).
frame(108, 4, ntdll, 'RtlUserThreadStart', 33).
S = <...>.

?- frames_agree('dump1.log', 108, 'frames108.pl').
true.
```

```{.prolog .query}
?- log_line('bad.log', 214, T),
   sub_atom(T, _, 27, 0, CallSite).
T = <...>,
CallSite = 'appserver!Housekeeping::Run'.

?- catch(
       write_frames('bad.log', 108, 'bad108.pl'),
       error(E, context(_, Where)), true).
E = syntax_error(k_line),
Where = 'bad.log:214: 02 <...>Housekeeping::Run'.

?- exists_file('bad108.pl').
false.

?- write_frames('bad.log', 108, 'bad108.pl').
ERROR: Syntax error: k_line (bad.log:214: 02 <...>
...
```

```{.prolog .query}
?- catch(check_keys([ frame(108, 0, a, 'A', 1),
                      frame(108, 1, b, 'B', 2),
                      frame(108, 0, c, 'C', 3)
                    ]),
         error(E, _), true).
E = domain_error(unique_frame_key, 108-0).

?- check_keys([ frame(108, 0, a, 'A', 1),
                frame(109, 0, b, 'B', 2) ]).
true.
```

```{.prolog .program}
% write_frame(Frame): write a frame/5 term as a
% fact with a hexadecimal offset.
write_frame(frame(T, N, M, F, O)) :-
    format("frame(~d, ~d, ~q, ~q, 0x~16r).~n",
           [T, N, M, F, O]).
```

```{.prolog .query}
?- frame(109, 0, M, F, O),
   write_frame(frame(109, 0, M, F, O)).
frame(109, 0, dbclient, 'Buffer::Copy', 0x1a).
M = dbclient,
F = 'Buffer::Copy',
O = 26.
```

## 15.4 Normalization

```{.prolog .program}
% module_atom(Text, Module): Module is the schema
% atom for a module the debugger names Text.
module_atom(Text, Module) :-
    file_name_extension(Stem, _, Text),
    downcase_atom(Stem, Module).
```

```{.prolog .query}
?- module_atom('KERNELBASE.dll', M).
M = kernelbase.

?- module_atom('KERNELBASE', M).
M = kernelbase.

?- module_atom('AppServer.exe', M).
M = appserver.

?- forall(frame(_, _, M, _, _), module(M, _, _)).
true.

?- forall(hooked(_, M, H),
   ( module(M, _, _), module(H, _, _) )).
true.
```

```{.prolog .query}
?- X is 0x1018, Y is 0x6c.
X = 4120,
Y = 108.
```

```{.prolog .program}
% raw_fields(+Raw, -State, -Woken, -Waiters): the
% fields packed in Raw, the LockCount field of a
% critical section as Windows Server 2003 SP1 and
% later store it: bit 0 is 1 when the section is
% unlocked, bit 1 is 1 when no waiting thread has
% been woken, and the bits above are the ones'
% complement of the number of waiting threads.
% State is locked or unlocked; Woken is woken or
% none.
raw_fields(Raw, State, Woken, Waiters) :-
    must_be(integer, Raw),
    (   Raw /\ 1 =:= 1
    ->  State = unlocked
    ;   State = locked
    ),
    (   Raw /\ 2 =:= 2
    ->  Woken = none
    ;   Woken = woken
    ),
    Waiters is (-1 - Raw) >> 2,
    (   Waiters >= 0
    ->  true
    ;   domain_error(lock_count_field, Raw)
    ).

% waiters_from_raw(+Raw, -Waiters): the number of
% waiting threads encoded in Raw; the normalized
% WaiterCount of critical_section/4 for a parser
% that reads the field under this encoding.
waiters_from_raw(Raw, Waiters) :-
    raw_fields(Raw, _, _, Waiters).

% raw_from_fields(+State, +Woken, +Waiters, -Raw):
% the inverse of raw_fields/4, for checking it.
raw_from_fields(State, Woken, Waiters, Raw) :-
    (   State == unlocked -> B0 = 1 ; B0 = 0 ),
    (   Woken == none -> B1 = 1 ; B1 = 0 ),
    Raw is ((\ Waiters) << 2) \/ (B1 << 1) \/ B0.
```

```{.prolog .query}
?- raw_fields(-1, S, K, W).
S = unlocked,
K = none,
W = 0.

?- raw_fields(-2, S, K, W).
S = locked,
K = none,
W = 0.

?- waiters_from_raw(-6, W).
W = 1.

?- waiters_from_raw(-10, W).
W = 2.

?- raw_from_fields(locked, none, 2, Raw),
   format("~2r~n", [Raw]).
-1010
Raw = -10.

?- forall(( between(0, 1000, N),
            member(S-K, [locked-none,
                         locked-woken,
                         unlocked-none]) ),
          ( raw_from_fields(S, K, N, R),
            raw_fields(R, S, K, N) )).
true.

?- catch(waiters_from_raw(0xfffffffa, W),
         error(E, _), true).
E = domain_error(lock_count_field, 4294967290).
```

## 15.5 Unknowns and Provenance

```{.prolog .query}
?- module(M, _, _), \+ module_info(M, company, _).
M = ntdll ;
M = kernelbase ;
M = kernel32 ;
M = ucrtbase ;
M = msvcp140 ;
false.
```

```{.prolog .query}
?- thread(T, _), \+ last_error(T, _).
T = 105 ;
T = 106 ;
T = 107 ;
T = 108 ;
false.
```

```{.prolog .program}
% source(Relation, Command, Log): the facts of
% Relation were parsed from the output of Command
% in the log file Log.
source(process/2, '!analyze -v', 'dump1.log').
source(module/3, lm, 'dump1.log').
source(module_info/3, lmv, 'dump1.log').
source(thread/2, '~*kn', 'dump1.log').
source(thread_time/3, '!runaway 7', 'dump1.log').
source(thread_state/2, derived, 'dump1.log').
source(frame/5, '~*kn', 'dump1.log').
source(exception_record/3, '.exr -1',
       'dump1.log').
source(exception_info/3, '.exr -1', 'dump1.log').
source(critical_section/4, '!locks', 'dump1.log').
source(waits_for/3, '!cs', 'dump1.log').
source(handle_count/3, '!handle 0 0',
       'dump1.log').
source(heap/4, '!heap -s', 'dump1.log').
source(last_error/2, '!teb', 'dump1.log').
source(last_status/2, '!teb', 'dump1.log').
source(hooked/3, analyst, 'dump1.notes').
```

```{.prolog .query}
?- schema(R, _), \+ source(R, _, _).
false.

?- source(R, '~*kn', _).
R = thread/2 ;
R = frame/5.

?- source(R, C, _), \+ source(R, _, 'dump1.log').
R = hooked/3,
C = analyst.
```

```{.prolog .program}
:- dynamic dump_info/2, ran/2, covering/2.

% last_status(TID, Status): the nonzero
% LastStatusValue that !teb prints for thread TID,
% from the same output as last_error/2. An
% extension of the schema, declared dynamic: the
% six inspected threads had none, so the relation
% is defined and has no facts.
:- dynamic last_status/2.

% dump_info(Key, Value): how the dump was written,
% as the analyst recorded it. An extension of the
% schema; dump1.pl does not contain it.
dump_info(file, 'dump1.dmp').
dump_info(writer, '.dump /ma').
dump_info(memory, full).
dump_info(stacks, unfiltered).
dump_info(stream, thread_list).
dump_info(stream, module_list).
dump_info(stream, exception).
dump_info(stream, thread_info).
dump_info(stream, handle_data).
dump_info(stream, unloaded_modules).

% ran(Command, Outcome): the parser found the
% output of Command in the log; Outcome is ok when
% it parsed, or failed(LineNo) when the debugger
% printed an error in its place at that line.
ran('!analyze -v', ok).
ran(lm, ok).
ran(lmv, ok).
ran('~*kn', ok).
ran('!runaway 7', ok).
ran('.exr -1', ok).
ran('!locks', ok).
ran('!cs', ok).
ran('!handle 0 0', ok).
ran('!heap -s', ok).
ran('!teb', ok).

% covering(Command, TID): the parser found the
% output of the per-thread Command for thread TID.
covering('~*kn', 100).
covering('~*kn', 101).
covering('~*kn', 102).
covering('~*kn', 103).
covering('~*kn', 104).
covering('~*kn', 105).
covering('~*kn', 106).
covering('~*kn', 107).
covering('~*kn', 108).
covering('~*kn', 109).
covering('!teb', 100).
covering('!teb', 101).
covering('!teb', 102).
covering('!teb', 103).
covering('!teb', 104).
covering('!teb', 109).
```

```{.prolog .program}
% need(Need): the vocabulary of capture needs.
need(stream(_)).
need(memory(_)).
need(stacks(_)).
need(relation(_)).
need(every_thread(_)).

% capture_policy(Relation, Needs): the facts of
% Relation are complete when the command of
% source/3 ran and succeeded and the capture meets
% every need in Needs. Every relation of the
% schema declares one; an empty list is a policy.
capture_policy(process/2, []).
capture_policy(module/3, [stream(module_list)]).
capture_policy(module_info/3,
               [stream(module_list),
                memory(full)]).
capture_policy(thread/2, [stream(thread_list)]).
capture_policy(thread_time/3,
               [stream(thread_list),
                stream(thread_info)]).
capture_policy(thread_state/2,
               [relation(thread/2),
                relation(exception_record/3),
                relation(frame/5)]).
capture_policy(frame/5,
               [stream(thread_list),
                every_thread('~*kn')]).
capture_policy(exception_record/3, []).
capture_policy(exception_info/3, []).
capture_policy(critical_section/4,
               [memory(full)]).
capture_policy(waits_for/3,
               [memory(full), stacks(unfiltered),
                relation(frame/5)]).
capture_policy(handle_count/3,
               [stream(handle_data)]).
capture_policy(heap/4, [memory(full)]).
capture_policy(last_error/2,
               [stream(thread_list),
                every_thread('!teb')]).
capture_policy(last_status/2,
               [stream(thread_list),
                every_thread('!teb')]).
capture_policy(hooked/3, []).
```

```{.prolog .program}
% missing(Need, Scope, What): the recorded capture
% does not meet Need within Scope, which is all or
% thread(TID), and What names what is missing. A
% need outside the vocabulary raises an error.
missing(stream(S), _, stream(S)) :-
    \+ dump_info(stream, S).
missing(memory(M), _, memory(M)) :-
    \+ dump_info(memory, M).
missing(stacks(K), _, stacks(K)) :-
    \+ dump_info(stacks, K).
missing(relation(R), Scope,
        relation(R, Status)) :-
    coverage(R, Scope, Status),
    Status \== complete.
missing(every_thread(C), all, covering(C, T)) :-
    thread(T, _),
    \+ covering(C, T).
missing(every_thread(C), thread(T),
        covering(C, T)) :-
    \+ covering(C, T).
missing(Need, _, _) :-
    \+ need(Need),
    domain_error(capture_need, Need).

% coverage(Relation, Status): Status is complete
% when the absence of a fact of Relation may be
% read as evidence, incomplete(Missing) when the
% recorded capture or command run falls short in
% the ways Missing lists, and unknown when the
% policy, the capture, or the command's run is
% not recorded.
coverage(Relation, Status) :-
    coverage(Relation, all, Status).

% thread_coverage(Relation, TID, Status): as
% coverage/2, for the facts of Relation about
% thread TID alone.
thread_coverage(Relation, TID, Status) :-
    coverage(Relation, thread(TID), Status).

coverage(Relation, Scope, Status) :-
    (   capture_policy(Relation, Needs),
        dump_info(_, _),
        source(Relation, Command, _),
        (   Command == derived
        ->  Outcome = ok
        ;   ran(Command, Outcome)
        )
    ->  findall(What,
                ( member(Need, Needs),
                  missing(Need, Scope, What) ),
                Unmet),
        (   Outcome == ok
        ->  Missing = Unmet
        ;   Missing = [ran(Command, Outcome)
                       | Unmet]
        ),
        (   Missing == []
        ->  Status = complete
        ;   Status = incomplete(Missing)
        )
    ;   Status = unknown
    ).
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.

?- coverage(handle_count/3, S).
S = complete.

?- coverage(thread_state/2, S).
S = complete.

?- coverage(hooked/3, S).
S = unknown.

?- coverage(last_error/2, incomplete(_Missing)),
   forall(member(M, _Missing), (print(M), nl)).
covering('!teb',105)
covering('!teb',106)
covering('!teb',107)
covering('!teb',108)
true.

?- thread_coverage(last_error/2, 109, S).
S = complete.

?- thread_coverage(last_error/2, 105, S).
S = incomplete([covering('!teb', 105)]).

?- forall(schema(R, _),
   ( coverage(R, S), functor(S, Name, _),
     format("~w~t~20|~w~n", [R, Name]) )).
process/2           complete
module/3            complete
module_info/3       complete
thread/2            complete
thread_time/3       complete
thread_state/2      complete
frame/5             complete
exception_record/3  complete
exception_info/3    complete
critical_section/4  complete
waits_for/3         complete
handle_count/3      complete
heap/4              complete
last_error/2        incomplete
hooked/3            unknown
true.
```

```{.prolog .program}
% thread_absence(Relation, TID, Status): Status is
% present when Relation is defined and has a fact
% whose first argument is TID, absent when it has
% none and the coverage of Relation for TID is
% complete, and unknown otherwise. A relation
% that is not defined has no fact; an error raised
% by one that is defined is not caught.
thread_absence(F/A, TID, Status) :-
    (   current_predicate(F/A),
        functor(Goal, F, A),
        arg(1, Goal, TID),
        call(Goal)
    ->  Status = present
    ;   thread_coverage(F/A, TID, complete)
    ->  Status = absent
    ;   Status = unknown
    ).
```

```{.prolog .query}
?- thread_absence(last_error/2, 109, S).
S = present.

?- thread_absence(last_error/2, 105, S).
S = unknown.

?- thread_absence(unrecorded/2, 105, S).
S = unknown.
```

```{.prolog .program}
% without_facts(Pattern, Goal): call Goal once
% with every fact matching Pattern retracted; the
% facts are restored afterwards, whether Goal
% succeeds, fails, or raises.
without_facts(Pattern, Goal) :-
    findall(Pattern, Pattern, Facts),
    setup_call_cleanup(
        retractall(Pattern),
        once(Goal),
        maplist(assertz, Facts)).

% with_fact(Fact, Goal): call Goal once with Fact
% added; Fact is retracted afterwards.
with_fact(Fact, Goal) :-
    setup_call_cleanup(
        assertz(Fact),
        once(Goal),
        retract(Fact)).
```

```{.prolog .query}
?- without_facts(dump_info(stream, handle_data),
                 coverage(handle_count/3, S)).
S = incomplete([stream(handle_data)]).

?- without_facts(dump_info(_, _),
                 coverage(frame/5, S)).
S = unknown.

?- without_facts(dump_info(_, _),
                 coverage(exception_record/3, S)).
S = unknown.

?- without_facts(ran('!handle 0 0', _),
                 coverage(handle_count/3, S)).
S = unknown.

?- without_facts(ran('!heap -s', _),
       with_fact(ran('!heap -s', failed(812)),
                 coverage(heap/4, S))).
S = incomplete([ran('!heap -s', failed(812))]).

?- without_facts(covering('~*kn', 107),
                 coverage(thread_state/2, _S)),
   _S = incomplete([relation(R, incomplete(M))]).
R = frame/5,
M = [covering('~*kn', 107)].

?- with_fact(covering('!teb', 105),
       thread_absence(last_error/2, 105, S)).
S = absent.

?- thread_absence(last_status/2, 105, S).
S = unknown.

?- thread_absence(last_status/2, 109, S).
S = absent.

?- with_fact(last_status(109, 0xc0000034),
       thread_absence(last_status/2, 109, S)).
S = present.

?- coverage(handle_count/3, complete),
   coverage(heap/4, complete),
   thread_absence(last_error/2, 105, unknown),
   \+ last_status(_, _),
   aggregate_all(count, dump_info(_, _), N).
N = 10.
```

## 15.6 Kernel and Complete Memory Dumps

```prolog
% frame(PID, TID, N, Module, Function, Offset)
frame(4120, 109, 0, dbclient, 'Buffer::Copy',
      0x1a).

% module(PID, Name, Base, Size)
module(4120, dbclient, 0x7ffb_8d10_0000, 0x6e000).
```

## 15.7 The Shared Dump

```{.prolog .query}
?- listing(waits_for/3).
waits_for(101, critical_section, 140695026507968).
waits_for(103, critical_section, 140695026508096).
waits_for(104, critical_section, 140695026507968).

true.

?- listing(critical_section/4).
critical_section(140695026507968, 103, 2, 1).
critical_section(140695026508096, 104, 1, 1).
critical_section(140695026508224, 0, 0, 0).

true.
```

```{.prolog .query}
?- exception_record(T, Code, Addr),
   format("~16r at ~16r~n", [Code, Addr]).
c0000005 at 7ffb8d1031aa
T = 109,
Code = 3221225477,
Addr = 140718380167594.

?- exception_info(109, K, V).
K = access,
V = read ;
K = target,
V = 24.
```

```{.prolog .query}
?- module_info(M, symbols, S), S \== pdb.
M = dbclient,
S = export ;
M = cachelib,
S = none ;
M = thirdparty_hook,
S = none.

?- module_info(M, version, V),
   module_info(M, company, 'Example Corp').
M = appserver,
V = '3.2.1.0' ;
M = reportengine,
V = '3.2.1.0' ;
M = dbclient,
V = '3.1.0.7' ;
false.
```

```{.prolog .program}
% invariant(Name): the named invariant of the
% schema holds in the loaded knowledge base.
invariant(frame_module_loaded) :-
    forall(frame(_, _, M, _, _), module(M, _, _)).
invariant(thread_has_time) :-
    forall(thread(T, _), thread_time(T, _, _)).
invariant(thread_has_state) :-
    forall(thread(T, _), thread_state(T, _)).
invariant(thread_has_top_frame) :-
    forall(thread(T, _), frame(T, 0, _, _, _)).
invariant(frames_contiguous) :-
    forall(( frame(T, N, _, _, _), N > 0 ),
           ( N0 is N - 1,
             frame(T, N0, _, _, _)
           )).
invariant(wait_target_listed) :-
    forall(waits_for(_, critical_section, A),
           critical_section(A, _, _, _)).
invariant(owner_is_thread) :-
    forall(( critical_section(_, O, _, _),
             O =\= 0
           ),
           thread(O, _)).
invariant(exception_thread_exists) :-
    forall(exception_record(T, _, _),
           thread(T, _)).

% check_schema: print the name of every invariant
% that does not hold.
check_schema :-
    forall(( clause(invariant(Name), _),
             \+ invariant(Name)
           ),
           format("violated: ~w~n", [Name])).
```

```{.prolog .query}
?- check_schema.
true.

?- aggregate_all(count, clause(invariant(_), _),
   N).
N = 8.
```

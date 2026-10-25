# Chapter 18. Stack Traces and Threads

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/18-stack-traces-and-threads.md`.

```{.prolog .program}
:- [dump1].
:- use_module(library(pprint)).

% threshold(Name, Value): the thresholds of this
% chapter, as facts an analyst can inspect.
threshold(spiking_share, 25).
threshold(frame_run, 4).
threshold(set_size, 2).

% pattern(Name, Artifact, Chapter): the patterns
% this chapter recognizes with a predicate.
pattern('Stack Trace', memory_dump, 18).
pattern(
    'Stack Trace Collection (Unmanaged Space)',
    memory_dump, 18).
pattern('Stack Trace Collection (Predicate)',
        memory_dump, 18).
pattern('Main Thread', memory_dump, 18).
pattern('Special Thread', memory_dump, 18).
pattern('Passive Thread', memory_dump, 18).
pattern('Spiking Thread', memory_dump, 18).
pattern('Blocked Thread (Software)',
    memory_dump, 18).
pattern('Active Thread', memory_dump, 18).
pattern('Stack Trace Signature', memory_dump, 18).
pattern('Least Common Frame', memory_dump, 18).
pattern('Stack Trace Set', memory_dump, 18).
pattern('Frame Regularity', memory_dump, 18).
pattern('Caller-n-Callee', memory_dump, 18).
pattern('Procedure Call Chain', memory_dump, 18).
pattern('Incorrect Stack Trace', memory_dump, 18).
pattern('Truncated Stack Trace', memory_dump, 18).
pattern('Coincidental Symbolic Information',
        memory_dump, 18).
pattern('Glued Stack Trace', memory_dump, 18).
pattern('Execution Residue (User Space)',
        memory_dump, 18).

% show(Term): print Term over several lines that
% fit the width of this book's pages.
show(Term) :-
    print_term(Term, [right_margin(46),
                      tab_width(0)]),
    nl.
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.
```

## 18.1 Stack Trace

```{.prolog .program}
% stack_trace(TID, Frames): Frames is the list of
% frame/5 terms of thread TID, top frame first.
stack_trace(TID, Frames) :-
    findall(frame(TID, N, M, F, O),
            frame(TID, N, M, F, O), Frames0),
    sort(2, @=<, Frames0, Frames).

% frame_symbol(Frame, Symbol): Symbol is the
% debugger's text for the frame/5 term Frame.
frame_symbol(frame(_, _, M, F, O), Symbol) :-
    (   F == 'Unknown'
    ->  format(atom(Symbol), "~a+0x~16r", [M, O])
    ;   format(atom(Symbol), "~a!~a+0x~16r",
               [M, F, O])
    ).

% print_stack_trace(TID): print the stack trace of
% TID one frame per line, numbered as k does.
print_stack_trace(TID) :-
    stack_trace(TID, Frames),
    forall(member(Frame, Frames),
           ( Frame = frame(_, N, _, _, _),
             frame_symbol(Frame, Symbol),
             format("~`0t~d~2| ~a~n", [N, Symbol])
           )).
```

```{.prolog .query}
?- stack_trace(103, _Frames), length(_Frames, N).
N = 10.

?- print_stack_trace(103).
00 ntdll!NtWaitForAlertByThreadId+0x14
01 ntdll!RtlpWaitOnCriticalSection+0x1cf
02 ntdll!RtlpEnterCriticalSectionContended+0x1cd
03 ntdll!RtlEnterCriticalSection+0x40
04 dbclient!Connection::Send+0x58
05 appserver!Session::Commit+0x9e
06 appserver!Worker::Run+0x120
07 ucrtbase!thread_start<...>+0x42
08 kernel32!BaseThreadInitThunk+0x14
09 ntdll!RtlUserThreadStart+0x21
true.

?- stack_trace(999, Frames).
Frames = [].
```

## 18.2 Stack Trace Collection (Unmanaged Space)

```{.prolog .program}
% stack_trace_collection(Collection): Collection
% is the list of TID-Frames pairs, one per thread.
stack_trace_collection(Collection) :-
    findall(TID-Frames,
            ( thread(TID, _),
              stack_trace(TID, Frames)
            ),
            Collection).

% print_top_frames(Collection): one line per
% thread with the symbol of its top frame.
print_top_frames(Collection) :-
    forall(member(TID-[Top | _], Collection),
           ( frame_symbol(Top, Symbol),
             format("~d ~a~n", [TID, Symbol])
           )).
```

```{.prolog .query}
?- stack_trace_collection(_C), length(_C, N).
N = 10.

?- stack_trace_collection(_C),
   print_top_frames(_C).
100 ntdll!NtWaitForMultipleObjects+0x14
101 ntdll!NtWaitForAlertByThreadId+0x14
102 reportengine!Table::Find+0x3e
103 ntdll!NtWaitForAlertByThreadId+0x14
104 ntdll!NtWaitForAlertByThreadId+0x14
105 ntdll!NtWaitForWorkViaWorkerFactory+0x14
106 ntdll!NtWaitForWorkViaWorkerFactory+0x14
107 reportengine!Node::Visit+0x12
108 ntdll!NtDelayExecution+0x14
109 dbclient!Buffer::Copy+0x1a
true.
```

## 18.3 Stack Trace Collection (Predicate)

```{.prolog .program}
% stack_trace_collection(Pred, Collection): the
% stack traces of the threads whose frame list
% satisfies the closure Pred.
stack_trace_collection(Pred, Collection) :-
    stack_trace_collection(All),
    include([_-Frames]>>call(Pred, Frames), All,
            Collection).

% has_module(Module, Frames): some frame of the
% list Frames is in Module.
has_module(Module, Frames) :-
    memberchk(frame(_, _, Module, _, _), Frames).

% has_function(F, Frames): some frame of the list
% Frames names the function F.
has_function(F, Frames) :-
    memberchk(frame(_, _, _, F, _), Frames).
```

```{.prolog .query}
?- stack_trace_collection(has_module(dbclient),
   _C), pairs_keys(_C, TIDs).
TIDs = [103, 104, 109].

?- stack_trace_collection(
   has_function('Worker::Run'), _C),
   pairs_keys(_C, TIDs).
TIDs = [101, 102, 103, 107, 109].

?- stack_trace_collection(
   [Fs]>>(length(Fs, D), D > 9), _C),
   pairs_keys(_C, TIDs).
TIDs = [101, 103, 104, 107].
```

## 18.4 Main Thread

```{.prolog .program}
% entry_function(F): F is an entry function that
% the main thread's stack trace passes through.
entry_function(main).
entry_function(wmain).
entry_function('WinMain').
entry_function('wWinMain').

% main_thread(TID): TID is the main thread.
main_thread(TID) :-
    thread(TID, _),
    once(( frame(TID, _, _, F, _),
           entry_function(F)
         )).
```

```{.prolog .query}
?- main_thread(T).
T = 100 ;
false.

?- main_thread(T), print_stack_trace(T).
00 ntdll!NtWaitForMultipleObjects+0x14
01 kernelbase!WaitForMultipleObjectsEx+0xe9
02 appserver!MainLoop+0x1b2
03 appserver!wmain+0x55
04 appserver!invoke_main+0x22
05 kernel32!BaseThreadInitThunk+0x14
06 ntdll!RtlUserThreadStart+0x21
T = 100 ;
false.
```

## 18.5 Special Thread

```{.prolog .program}
% special_frame(Function, Role): a frame naming
% Function marks a thread as serving Role.
special_frame('TppWorkerThread', thread_pool).
special_frame('DbgUiRemoteBreakin', debugger).

% special_thread(TID, Role): TID is a thread of
% the system or runtime serving Role.
special_thread(TID, Role) :-
    thread(TID, _),
    frame(TID, _, _, F, _),
    special_frame(F, Role).
```

```{.prolog .query}
?- special_thread(T, R).
T = 105,
R = thread_pool ;
T = 106,
R = thread_pool ;
false.
```

## 18.6 Passive Thread

```{.prolog .program}
% passive_thread(TID): TID waits on a user request
% and is not recorded as waiting for an object.
passive_thread(TID) :-
    thread_state(TID, waiting(user_request)),
    \+ waits_for(TID, _, _).
```

```{.prolog .query}
?- passive_thread(T).
T = 100 ;
T = 105 ;
T = 106.

?- passive_thread(T), \+ special_thread(T, _).
T = 100 ;
false.
```

## 18.7 Spiking Thread

```{.prolog .program}
% cpu_time(TID, Ms): the CPU time of TID in ms.
cpu_time(TID, Ms) :-
    thread_time(TID, User, Kernel),
    Ms is User + Kernel.

% total_cpu(Total): the CPU time of all threads.
total_cpu(Total) :-
    aggregate_all(sum(Ms), cpu_time(_, Ms),
                  Total).

% cpu_share(TID, Share): the CPU time of TID as a
% percentage of the total.
cpu_share(TID, Share) :-
    cpu_time(TID, Ms),
    total_cpu(Total),
    Total > 0,
    Share is 100.0 * Ms / Total.

% spiking_thread(TID): the CPU share of TID is at
% least the threshold.
spiking_thread(TID) :-
    cpu_share(TID, Share),
    threshold(spiking_share, Min),
    Share >= Min.

% spiking_thread(TID, Evidence): as the test
% above, with the evidence of the recognition.
spiking_thread(TID, Evidence) :-
    spiking_thread(TID),
    cpu_time(TID, Ms),
    total_cpu(Total),
    threshold(spiking_share, Min),
    Evidence = evidence('Spiking Thread', TID,
                        [ cpu_time(TID, Ms),
                          total_cpu(Total),
                          threshold(spiking_share,
                                    Min)
                        ]).
```

```{.prolog .query}
?- spiking_thread(T).
T = 102 ;
T = 107 ;
false.

?- spiking_thread(107, _E), show(_E).
evidence('Spiking Thread',
         107,
         [ cpu_time(107,4100),
           total_cpu(14135),
           threshold(spiking_share,25)
         ])
true.

?- spiking_thread(100, E).
false.
```

## 18.8 Blocked Thread (Software)

```{.prolog .program}
% blocked_thread(TID): the dump records an object
% TID waits for.
blocked_thread(TID) :-
    waits_for(TID, _, _).

% wait_function(F): F is a frame of the critical
% section wait path in ntdll.
wait_function('RtlpWaitOnCriticalSection').
wait_function('RtlEnterCriticalSection').

% blocked_thread(TID, Evidence): as
% blocked_thread/1, with the object and the wait
% frames as evidence.
blocked_thread(TID, Evidence) :-
    waits_for(TID, Kind, Addr),
    findall(frame(TID, N, M, F, O),
            ( frame(TID, N, M, F, O),
              wait_function(F)
            ),
            Frames),
    Facts = [waits_for(TID, Kind, Addr) | Frames],
    Name = 'Blocked Thread (Software)',
    Evidence = evidence(Name, TID, Facts).
```

```{.prolog .query}
?- blocked_thread(T).
T = 101 ;
T = 103 ;
T = 104.

?- blocked_thread(104, _E), show(_E).
evidence('Blocked Thread (Software)',
         104,
         [ waits_for(104,
                     critical_section,
                     140695026507968),
           frame(104,
                 1,
                 ntdll,
                 'RtlpWaitOnCriticalSection',
                 463),
           frame(104,
                 3,
                 ntdll,
                 'RtlEnterCriticalSection',
                 64)
         ])
true.

?- forall(blocked_thread(T),
   frame(T, _, ntdll,
         'RtlpWaitOnCriticalSection', _)).
true.
```

## 18.9 Active Thread

```{.prolog .program}
% active_thread(TID): TID was running when the
% dump was written.
active_thread(TID) :-
    thread_state(TID, running).
```

```{.prolog .query}
?- active_thread(T).
T = 102 ;
T = 107.

?- active_thread(T), spiking_thread(T).
T = 102 ;
T = 107.

?- thread_state(109, S).
S = waiting(exception).
```

## 18.10 Thread Age

## 18.11 Stack Trace Signature

```{.prolog .program}
% frame_key(Frame, Key): Key is the pair
% Module-Function of the frame/5 term Frame.
frame_key(frame(_, _, M, F, _), M-F).

% stack_trace_signature(TID, Signature): the keys
% of the frames of TID, top frame first.
stack_trace_signature(TID, Signature) :-
    stack_trace(TID, Frames),
    maplist(frame_key, Frames, Signature).

% top_signature(TID, Depth, Signature): the keys
% of the top Depth frames of TID.
top_signature(TID, Depth, Signature) :-
    stack_trace_signature(TID, Full),
    length(Signature, Depth),
    append(Signature, _, Full).
```

```{.prolog .query}
?- stack_trace_signature(105, _S), show(_S).
[ ntdll-'NtWaitForWorkViaWorkerFactory',
  ntdll-'TppWorkerThread',
  kernel32-'BaseThreadInitThunk',
  ntdll-'RtlUserThreadStart'
]
true.

?- stack_trace_signature(105, _A),
   stack_trace_signature(106, _B), _A == _B.
true.

?- top_signature(109, 1, S).
S = [dbclient-'Buffer::Copy'].

?- top_signature(105, 6, S).
false.
```

## 18.12 Least Common Frame

```{.prolog .program}
% reversed_signature(TID, Reversed): the signature
% of TID from the bottom frame up.
reversed_signature(TID, Reversed) :-
    stack_trace_signature(TID, Signature),
    reverse(Signature, Reversed).

% common_prefix(Lists, Prefix): Prefix is the
% longest list that every list in Lists begins
% with.
common_prefix(Lists, Prefix) :-
    (   Lists = [[X | _] | _],
        forall(member(L, Lists), L = [X | _])
    ->  maplist(list_tail, Lists, Tails),
        common_prefix(Tails, Prefix0),
        Prefix = [X | Prefix0]
    ;   Prefix = []
    ).

list_tail([_ | Tail], Tail).

% least_common_frame(TIDs, Key): Key is the
% topmost frame key shared, as a common suffix, by
% the stack traces of all threads in TIDs.
least_common_frame(TIDs, Key) :-
    maplist(reversed_signature, TIDs, Reversed),
    common_prefix(Reversed, Common),
    last(Common, Key).
```

```{.prolog .query}
?- least_common_frame([101, 103], K).
K = appserver-'Worker::Run'.

?- least_common_frame([101, 103, 104], K).
K = ucrtbase-'thread_start<...>'.

?- least_common_frame([100, 105], K).
K = kernel32-'BaseThreadInitThunk'.

?- findall(T, thread(T, _), _Ts),
   least_common_frame(_Ts, K).
K = kernel32-'BaseThreadInitThunk'.
```

## 18.13 Stack Trace Set

```{.prolog .program}
% stack_trace_set(Signature, TIDs): TIDs are the
% threads whose signature is Signature, at least
% the threshold many.
stack_trace_set(Sig, TIDs) :-
    bagof(TID,
          P^( thread(TID, P),
              stack_trace_signature(TID, Sig)
            ),
          TIDs),
    threshold(set_size, Min),
    length(TIDs, Size),
    Size >= Min.

% stack_trace_set(Depth, Signature, TIDs): as
% stack_trace_set/2 on the top Depth frames.
stack_trace_set(Depth, Sig, TIDs) :-
    bagof(TID,
          P^( thread(TID, P),
              top_signature(TID, Depth, Sig)
            ),
          TIDs),
    threshold(set_size, Min),
    length(TIDs, Size),
    Size >= Min.
```

```{.prolog .query}
?- stack_trace_set(_S, TIDs).
TIDs = [105, 106] ;
false.

?- stack_trace_set(4, _S, TIDs).
TIDs = [101, 103, 104] ;
TIDs = [105, 106] ;
false.

?- stack_trace_set(4, _S, TIDs), show(_S).
[ ntdll-'NtWaitForAlertByThreadId',
  ntdll-'RtlpWaitOnCriticalSection',
  ntdll-'RtlpEnterCriticalSectionContended',
  ntdll-'RtlEnterCriticalSection'
]
TIDs = [101, 103, 104] ;
[ ntdll-'NtWaitForWorkViaWorkerFactory',
  ntdll-'TppWorkerThread',
  kernel32-'BaseThreadInitThunk',
  ntdll-'RtlUserThreadStart'
]
TIDs = [105, 106] ;
false.
```

## 18.14 Frame Regularity

```{.prolog .program}
% runs(List, Runs): Runs is the list of X-N pairs,
% one per maximal run of N consecutive elements
% equal to X in List.
runs([], []).
runs([X | Xs], [X-N | Runs]) :-
    run_length(Xs, X, 1, N, Rest),
    runs(Rest, Runs).

run_length(Xs, X, N0, N, Rest) :-
    (   Xs = [Y | Xs1],
        Y == X
    ->  N1 is N0 + 1,
        run_length(Xs1, X, N1, N, Rest)
    ;   N = N0,
        Rest = Xs
    ).

% frame_regularity(TID, Key, Count): the signature
% of TID has a run of Count frames with Key, Count
% at least the threshold.
frame_regularity(TID, Key, Count) :-
    thread(TID, _),
    stack_trace_signature(TID, Signature),
    runs(Signature, Runs),
    member(Key-Count, Runs),
    threshold(frame_run, Min),
    Count >= Min.
```

```{.prolog .query}
?- frame_regularity(T, K, N).
T = 107,
K = reportengine-'Node::Visit',
N = 8 ;
false.

?- stack_trace_signature(103, _S), runs(_S, _R),
   pairs_values(_R, _Ls), max_list(_Ls, Longest).
Longest = 1.
```

## 18.15 Caller-n-Callee

```{.prolog .program}
% caller_n_callee(Caller, Callee, TID): in the
% stack trace of TID the frame with key Callee is
% directly above the frame with key Caller.
caller_n_callee(Caller, Callee, TID) :-
    thread(TID, _),
    stack_trace_signature(TID, Signature),
    nextto(Callee, Caller, Signature).
```

```{.prolog .query}
?- caller_n_callee(C,
   ntdll-'RtlEnterCriticalSection', T).
C = cachelib-'Unknown',
T = 101 ;
C = dbclient-'Connection::Send',
T = 103 ;
C = appserver-'Session::Lookup',
T = 104 ;
false.

?- caller_n_callee(appserver-'Worker::Run', C, T).
C = appserver-'Session::Lookup',
T = 101 ;
C = reportengine-'Report::Build',
T = 102 ;
C = appserver-'Session::Commit',
T = 103 ;
C = reportengine-'Report::Build',
T = 107 ;
C = appserver-'Session::Fetch',
T = 109 ;
false.
```

## 18.16 Procedure Call Chain

```{.prolog .program}
% procedure_call_chain(TID, Chain): Chain is the
% list of functions of TID from the bottom frame
% to the top, in the order the calls were made.
procedure_call_chain(TID, Chain) :-
    reversed_signature(TID, Reversed),
    pairs_values(Reversed, Chain).

% chain_contains(TID, Sub): Sub is a contiguous
% part of the call chain of TID.
chain_contains(TID, Sub) :-
    procedure_call_chain(TID, Chain),
    append(_, Rest, Chain),
    append(Sub, _, Rest).
```

```{.prolog .query}
?- procedure_call_chain(109, _C), show(_C).
[ 'RtlUserThreadStart',
  'BaseThreadInitThunk',
  'thread_start<...>',
  'Worker::Run',
  'Session::Fetch',
  'Connection::Receive',
  'Buffer::Copy'
]
true.

?- thread(T, _),
   chain_contains(T,
   ['Worker::Run', 'Session::Lookup']).
T = 101 ;
false.

?- thread(T, _),
   chain_contains(T, ['Session::Lookup']).
T = 101 ;
T = 104 ;
false.
```

## 18.17 Incorrect Stack Trace

```{.prolog .program}
% incorrect_stack_trace(TID, Reason): the stack
% trace of TID may be incorrect for Reason, a
% module on it without full symbols.
incorrect_stack_trace(TID, no_symbols(M)) :-
    thread(TID, _),
    distinct(M, frame(TID, _, M, _, _)),
    module_info(M, symbols, none).
incorrect_stack_trace(TID, export_symbols(M)) :-
    thread(TID, _),
    distinct(M, frame(TID, _, M, _, _)),
    module_info(M, symbols, export).
```

```{.prolog .query}
?- incorrect_stack_trace(T, R).
T = 101,
R = no_symbols(cachelib) ;
T = 103,
R = export_symbols(dbclient) ;
T = 104,
R = export_symbols(dbclient) ;
T = 109,
R = export_symbols(dbclient) ;
false.
```

## 18.18 Truncated Stack Trace

```{.prolog .program}
% bottom_function(F): F ends a complete user-mode
% stack trace.
bottom_function('RtlUserThreadStart').
bottom_function('LdrInitializeThunk').

% truncated_frames(Frames): the non-empty frame
% list Frames does not end in a bottom function.
truncated_frames(Frames) :-
    last(Frames, frame(_, _, _, F, _)),
    \+ bottom_function(F).

% truncated_stack_trace(TID): the stack trace of
% TID is truncated.
truncated_stack_trace(TID) :-
    thread(TID, _),
    stack_trace(TID, Frames),
    truncated_frames(Frames).
```

```{.prolog .query}
?- truncated_stack_trace(T).
false.

?- stack_trace(101, _F), length(_P, 5),
   append(_P, _, _F), truncated_frames(_P),
   last(_P, _Last), frame_symbol(_Last, S).
S = 'cachelib+0x2a10'.

?- truncated_frames([]).
false.
```

## 18.19 Coincidental Symbolic Information

```{.prolog .program}
% raw_stack(TID, Addr, Value): the word at stack
% address Addr of thread TID holds Value. An
% extension of the schema.
raw_stack(108, 0xf1_2bff_e8a0, 0x18).
raw_stack(108, 0xf1_2bff_e8a8, 0x7ffb_b0b0_8f5e).
raw_stack(108, 0xf1_2bff_e8b0, 0xf1_2bff_e900).
raw_stack(108, 0xf1_2bff_e8b8, 0x7ffb_b2a0_0000).
raw_stack(108, 0xf1_2bff_e8c0, 0x7ff6_1d10_3a2c).
raw_stack(108, 0xf1_2bff_e8c8, 0x7ffb_8d10_12c4).
raw_stack(108, 0xf1_2bff_e8d0, 0x1f4).
raw_stack(108, 0xf1_2bff_e8d8, 0x7ffb_6f30_1040).

% address_module(Addr, Module): Addr lies in the
% address range of Module.
address_module(Addr, Module) :-
    module(Module, Base, Size),
    Base =< Addr,
    Addr < Base + Size.

% symbol_like(Value, Module, Offset): Value lies
% in Module at Offset; dps would show a symbol.
symbol_like(Value, Module, Offset) :-
    address_module(Value, Module),
    module(Module, Base, _),
    Offset is Value - Base.

% coincidental_symbolic_information(TID, Addr, M):
% the raw stack word at Addr of TID lies in module
% M at a page-aligned offset.
coincidental_symbolic_information(TID, Addr, M) :-
    raw_stack(TID, Addr, Value),
    symbol_like(Value, M, Offset),
    Offset /\ 0xfff =:= 0.
```

```{.prolog .query}
?- raw_stack(108, A, V), symbol_like(V, M, O),
   format("~16r ~a+0x~16r~n", [A, M, O]), fail.
f12bffe8a8 kernelbase+0x8f5e
f12bffe8b8 ntdll+0x0
f12bffe8c0 appserver+0x3a2c
f12bffe8c8 dbclient+0x12c4
f12bffe8d8 thirdparty_hook+0x1040
false.

?- coincidental_symbolic_information(108, A, M),
   format("~16r~n", [A]).
f12bffe8b8
A = 1035825309880,
M = ntdll ;
false.
```

## 18.20 Glued Stack Trace

```{.prolog .program}
% glued_frames(Frames): some frame of the list
% Frames names a bottom function and is not the
% last frame.
glued_frames(Frames) :-
    append(_, [Frame, _ | _], Frames),
    Frame = frame(_, _, _, F, _),
    bottom_function(F).

% glued_stack_trace(TID): the stack trace of TID
% has a bottom function above another frame.
glued_stack_trace(TID) :-
    thread(TID, _),
    stack_trace(TID, Frames),
    glued_frames(Frames).
```

```{.prolog .query}
?- glued_stack_trace(T).
false.

?- stack_trace(105, _A), stack_trace(109, _B),
   append(_A, _B, _G), glued_frames(_G).
true ;
false.

?- stack_trace(105, _A), stack_trace(109, _B),
   append(_A, _B, _G), length(_G, N),
   nth0(I, _G, frame(_, _, _, F, _)),
   bottom_function(F).
N = 11,
I = 3,
F = 'RtlUserThreadStart' ;
N = 11,
I = 10,
F = 'RtlUserThreadStart'.
```

## 18.21 Execution Residue (User Space)

```{.prolog .program}
% execution_residue(TID, Addr, Module, Offset):
% the raw stack word at Addr of TID holds a code
% address of Module that is not page-aligned.
execution_residue(TID, Addr, Module, Offset) :-
    raw_stack(TID, Addr, Value),
    symbol_like(Value, Module, Offset),
    Offset /\ 0xfff =\= 0.
```

```{.prolog .query}
?- execution_residue(108, _, M, O),
   format("~a+0x~16r~n", [M, O]), fail.
kernelbase+0x8f5e
appserver+0x3a2c
dbclient+0x12c4
thirdparty_hook+0x1040
false.

?- execution_residue(108, _, M, _),
   \+ frame(108, _, M, _, _).
M = dbclient ;
M = thirdparty_hook.

?- print_stack_trace(108).
00 ntdll!NtDelayExecution+0x14
01 kernelbase!SleepEx+0x9e
02 appserver!Housekeeping::Run+0x3a
03 kernel32!BaseThreadInitThunk+0x14
04 ntdll!RtlUserThreadStart+0x21
true.
```

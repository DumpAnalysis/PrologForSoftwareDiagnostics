# Chapter 19. Exceptions and Faults

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/19-exceptions-and-faults.md`.

```{.prolog .program .small file=faults.pl}
% faults.pl -- dump1.pl extended with synthetic threads
% 110-119, each showing one fault configuration that the
% shared dump lacks. The threads do not form a consistent
% process state and are not meant to. An extension of the
% schema; every value is invented. Three relations are
% dynamic, so that Section 19.9 can add synthetic stacks
% and take them away again.
:- discontiguous module/3, module_info/3, thread/2,
   thread_time/3, thread_state/2, exception_record/3,
   exception_info/3.
:- dynamic thread/2, frame/5, exception_record/3.
:- include(dump1).

module(vcruntime140, 0x7ffb_9b10_0000, 0x1e000).
module(coreclr, 0x7ffb_7c00_0000, 0x5a0000).
module_info(vcruntime140, symbols, pdb).
module_info(coreclr, symbols, pdb).

thread(110, 4120).
thread(111, 4120).
thread(112, 4120).
thread(113, 4120).
thread(114, 4120).
thread(115, 4120).
thread(116, 4120).
thread(117, 4120).
thread(119, 4120).

thread_time(110, 10, 5).
thread_time(111, 20, 5).
thread_time(112, 15, 5).
thread_time(113, 30, 10).
thread_time(114, 25, 10).
thread_time(115, 20, 5).
thread_time(116, 15, 5).
thread_time(117, 10, 5).
thread_time(119, 400, 50).

thread_state(110, waiting(exception)).
thread_state(111, waiting(exception)).
thread_state(112, waiting(exception)).
thread_state(113, waiting(exception)).
thread_state(114, waiting(exception)).
thread_state(115, waiting(user_request)).
thread_state(116, waiting(exception)).
thread_state(117, waiting(exception)).
thread_state(119, waiting(exception)).

% 110: a call through a null function pointer
frame(110, 0, none, 'Unknown', 0).
frame(110, 1, appserver, 'Plugin::Invoke', 0x3c).
frame(110, 2, appserver, 'Worker::Run', 0x120).
frame(110, 3, ucrtbase, 'thread_start<...>', 0x42).
frame(110, 4, kernel32, 'BaseThreadInitThunk', 0x14).
frame(110, 5, ntdll, 'RtlUserThreadStart', 0x21).
exception_record(110, 0xc0000005, 0x0).
exception_info(110, access, execute).
exception_info(110, target, 0x0).

% 111: integer division by zero
frame(111, 0, reportengine, 'Stats::Mean', 0x40).
frame(111, 1, reportengine, 'Report::Summarize', 0x88).
frame(111, 2, appserver, 'Worker::Run', 0x120).
frame(111, 3, ucrtbase, 'thread_start<...>', 0x42).
frame(111, 4, kernel32, 'BaseThreadInitThunk', 0x14).
frame(111, 5, ntdll, 'RtlUserThreadStart', 0x21).
exception_record(111, 0xc0000094, 0x7ffb_8e41_2b40).

% 112: an unhandled C++ exception
frame(112, 0, kernelbase, 'RaiseException', 0x6e).
frame(112, 1, vcruntime140, '_CxxThrowException', 0x90).
frame(112, 2, appserver, 'Parser::Expect', 0x5a).
frame(112, 3, appserver, 'Parser::Parse', 0x1c4).
frame(112, 4, appserver, 'Worker::Run', 0x120).
frame(112, 5, ucrtbase, 'thread_start<...>', 0x42).
frame(112, 6, kernel32, 'BaseThreadInitThunk', 0x14).
frame(112, 7, ntdll, 'RtlUserThreadStart', 0x21).
exception_record(112, 0xe06d7363, 0x7ffb_b0b2_1a3e).

% 113: an unhandled managed exception; frame 3 is
% JIT-compiled code outside every module; the frames
% below it are abridged
frame(113, 0, kernelbase, 'RaiseException', 0x6e).
frame(113, 1, coreclr, 'RaiseTheExceptionInternalOnly', 0x2a8).
frame(113, 2, coreclr, 'IL_Throw', 0x1c0).
frame(113, 3, none, 'Unknown', 0).
frame(113, 4, kernel32, 'BaseThreadInitThunk', 0x14).
frame(113, 5, ntdll, 'RtlUserThreadStart', 0x21).
exception_record(113, 0xe0434352, 0x7ffb_b0b2_1a3e).

% 114: a C++ exception thrown by the handler of an
% access violation
frame(114, 0, kernelbase, 'RaiseException', 0x6e).
frame(114, 1, vcruntime140, '_CxxThrowException', 0x90).
frame(114, 2, appserver, 'Handler::Report', 0x66).
frame(114, 3, appserver, 'Handler::OnFault', 0x2e).
frame(114, 4, ntdll, 'RtlpExecuteHandlerForException', 0xf).
frame(114, 5, ntdll, 'RtlDispatchException', 0x244).
frame(114, 6, ntdll, 'KiUserExceptionDispatch', 0x2e).
frame(114, 7, dbclient, 'Buffer::Copy', 0x1a).
frame(114, 8, dbclient, 'Connection::Receive', 0x8c).
frame(114, 9, appserver, 'Session::Fetch', 0x44).
frame(114, 10, appserver, 'Worker::Run', 0x120).
frame(114, 11, ucrtbase, 'thread_start<...>', 0x42).
frame(114, 12, kernel32, 'BaseThreadInitThunk', 0x14).
frame(114, 13, ntdll, 'RtlUserThreadStart', 0x21).
exception_record(114, 0xe06d7363, 0x7ffb_b0b2_1a3e).

% 115: a handler waiting for a log flush; no current
% exception record
frame(115, 0, ntdll, 'NtWaitForSingleObject', 0x14).
frame(115, 1, kernelbase, 'WaitForSingleObjectEx', 0x8e).
frame(115, 2, appserver, 'Logger::Flush', 0x72).
frame(115, 3, appserver, 'Handler::OnFault', 0x4a).
frame(115, 4, ntdll, 'RtlpExecuteHandlerForException', 0xf).
frame(115, 5, ntdll, 'RtlDispatchException', 0x244).
frame(115, 6, ntdll, 'KiUserExceptionDispatch', 0x2e).
frame(115, 7, appserver, 'Session::Parse', 0xb0).
frame(115, 8, appserver, 'Worker::Run', 0x120).
frame(115, 9, ucrtbase, 'thread_start<...>', 0x42).
frame(115, 10, kernel32, 'BaseThreadInitThunk', 0x14).
frame(115, 11, ntdll, 'RtlUserThreadStart', 0x21).

% 116: a read through a pointer holding text
frame(116, 0, dbclient, 'Row::Get', 0x32).
frame(116, 1, dbclient, 'Cursor::Next', 0x7d).
frame(116, 2, appserver, 'Session::Fetch', 0x58).
frame(116, 3, appserver, 'Worker::Run', 0x120).
frame(116, 4, ucrtbase, 'thread_start<...>', 0x42).
frame(116, 5, kernel32, 'BaseThreadInitThunk', 0x14).
frame(116, 6, ntdll, 'RtlUserThreadStart', 0x21).
exception_record(116, 0xc0000005, 0x7ffb_8d10_4c12).
exception_info(116, access, read).
exception_info(116, target, 0x4141_4141).

% 117: execution at an address outside every module,
% with return addresses overwritten by text
frame(117, 0, none, 'Unknown', 0).
frame(117, 1, none, 'Unknown', 0).
frame(117, 2, none, 'Unknown', 0).
frame(117, 3, appserver, 'Parser::Parse', 0x1c4).
frame(117, 4, appserver, 'Worker::Run', 0x120).
frame(117, 5, ucrtbase, 'thread_start<...>', 0x42).
frame(117, 6, kernel32, 'BaseThreadInitThunk', 0x14).
frame(117, 7, ntdll, 'RtlUserThreadStart', 0x21).
exception_record(117, 0xc0000005, 0x4141_4141).
exception_info(117, access, execute).
exception_info(117, target, 0x4141_4141).

% 119: stack exhausted by recursion; the run of
% Node::Visit frames is abridged
frame(119, 0, reportengine, 'Node::Visit', 0x12).
frame(119, 1, reportengine, 'Node::Visit', 0x6b).
frame(119, 2, reportengine, 'Node::Visit', 0x6b).
frame(119, 3, reportengine, 'Node::Visit', 0x6b).
frame(119, 4, reportengine, 'Node::Visit', 0x6b).
frame(119, 5, reportengine, 'Node::Visit', 0x6b).
frame(119, 6, reportengine, 'Node::Visit', 0x6b).
frame(119, 7, reportengine, 'Tree::Walk', 0x30).
frame(119, 8, reportengine, 'Report::Build', 0x1f0).
frame(119, 9, appserver, 'Worker::Run', 0x120).
frame(119, 10, ucrtbase, 'thread_start<...>', 0x42).
frame(119, 11, kernel32, 'BaseThreadInitThunk', 0x14).
frame(119, 12, ntdll, 'RtlUserThreadStart', 0x21).
exception_record(119, 0xc00000fd, 0x7ffb_8e40_c012).

% frame_address(TID, N, Addr): the address of frame N
% of TID, recorded for the frames outside every module
% and their neighbors. An extension of the schema.
frame_address(110, 0, 0x0).
frame_address(110, 1, 0x7ff6_1d11_203c).
frame_address(117, 0, 0x4141_4141).
frame_address(117, 1, 0x4141_4141).
frame_address(117, 2, 0x4141_4141).
frame_address(117, 3, 0x7ff6_1d11_a1c4).

% stored_exception(TID, Addr, Code, ExcAddr): an
% exception record found in the memory of TID at Addr,
% recording exception Code raised at ExcAddr. An
% extension of the schema.
stored_exception(109, 0xf1_2aff_e2a0, 0xc0000005,
                 0x7ffb_8d10_31aa).
stored_exception(115, 0xf1_2cff_e5c0, 0xc0000005,
                 0x7ff6_1d11_b0c8).
```

```{.prolog .program}
:- use_module(library(pprint)).

% threshold(Name, Value): the thresholds.
% frame_run is Chapter 18's run length for a Frame
% Regularity; overflow_run is the longer run that
% makes a deep stack a suspected overflow.
threshold(null_page, 0x1_0000).
threshold(stack_depth, 12).
threshold(frame_run, 4).
threshold(overflow_run, 6).
threshold(text_bytes, 4).

% status_name(Code, Name): the name of a status
% code that marks a kind of exception.
status_name(0xc0000005, access_violation).
status_name(0xc0000094, divide_by_zero).
status_name(0xc00000fd, stack_overflow).
status_name(0xe06d7363, cpp_exception).
status_name(0xe0434352, clr_exception).
status_name(0x80000003, breakpoint).

% system_module(M): M belongs to the operating
% system or a runtime, not to the application.
system_module(ntdll).
system_module(kernelbase).
system_module(kernel32).
system_module(ucrtbase).
system_module(msvcp140).
system_module(vcruntime140).
system_module(coreclr).

% pattern(Name, Artifact, Chapter): the patterns
% this chapter recognizes with a predicate.
pattern('Exception Stack Trace', memory_dump, 19).
pattern('Fault Context', memory_dump, 19).
pattern('NULL Pointer (Data)', memory_dump, 19).
pattern('NULL Pointer (Code)', memory_dump, 19).
pattern('Invalid Pointer (General)',
    memory_dump, 19).
pattern('Wild Pointer', memory_dump, 19).
pattern('Wild Code', memory_dump, 19).
pattern('Local Buffer Overflow (User Space)',
        memory_dump, 19).
pattern('Stack Overflow (User Mode)',
    memory_dump, 19).
pattern('Divide by Zero (User Mode)',
    memory_dump, 19).
pattern('Nested Exceptions (User Space)',
        memory_dump, 19).
pattern('Multiple Exceptions (User Space)',
        memory_dump, 19).
pattern('Hidden Exception (User Space)',
        memory_dump, 19).
pattern('Handled Exception (User Space)',
        memory_dump, 19).
pattern('C++ Exception', memory_dump, 19).
pattern('Managed Code Exception',
    memory_dump, 19).
pattern('Stored Exception', memory_dump, 19).
pattern('Exception Module', memory_dump, 19).
pattern('Problem Module', memory_dump, 19).
pattern('Crash Signature', memory_dump, 19).

% show(Term): print Term over several lines that
% fit the width of this book's pages.
show(Term) :-
    print_term(Term, [right_margin(46),
                      tab_width(0)]),
    nl.

% address_module(Addr, Module): Addr lies in the
% address range of Module.
address_module(Addr, Module) :-
    module(Module, Base, Size),
    Base =< Addr,
    Addr < Base + Size.

% stack_trace(TID, Frames): the frame/5 terms of
% TID, top frame first.
stack_trace(TID, Frames) :-
    findall(frame(TID, N, M, F, O),
            frame(TID, N, M, F, O), Frames0),
    sort(2, @=<, Frames0, Frames).

% frame_symbol(Frame, Symbol): the debugger's text
% for Frame; the address alone for a frame in no
% module.
frame_symbol(frame(TID, N, M, F, O), Symbol) :-
    (   M == none
    ->  (   frame_address(TID, N, Addr)
        ->  format(atom(Symbol), "0x~16r", [Addr])
        ;   Symbol = '<no module>'
        )
    ;   F == 'Unknown'
    ->  format(atom(Symbol), "~a+0x~16r", [M, O])
    ;   format(atom(Symbol), "~a!~a+0x~16r",
               [M, F, O])
    ).

% print_stack_trace(TID): one line per frame.
print_stack_trace(TID) :-
    stack_trace(TID, Frames),
    forall(member(Frame, Frames),
           ( Frame = frame(_, N, _, _, _),
             frame_symbol(Frame, Symbol),
             format("~`0t~d~2| ~a~n", [N, Symbol])
           )).
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.

?- aggregate_all(count, thread(_, _), N).
N = 19.

?- aggregate_all(count,
                 exception_record(_, _, _), N).
N = 9.
```

## 19.1 Exception Stack Trace

```{.prolog .program}
% exception_stack_trace(TID, Frames): TID has an
% exception record and Frames is its stack trace.
exception_stack_trace(TID, Frames) :-
    exception_record(TID, _, _),
    stack_trace(TID, Frames).
```

```{.prolog .query}
?- exception_stack_trace(T, _Frames), T < 110,
   print_stack_trace(T).
00 dbclient!Buffer::Copy+0x1a
01 dbclient!Connection::Receive+0x8c
02 appserver!Session::Fetch+0x44
03 appserver!Worker::Run+0x120
04 ucrtbase!thread_start<...>+0x42
05 kernel32!BaseThreadInitThunk+0x14
06 ntdll!RtlUserThreadStart+0x21
T = 109 ;
false.

?- findall(T, exception_stack_trace(T, _), _Ts),
   length(_Ts, N), last(_Ts, Last).
N = 9,
Last = 119.
```

## 19.2 Fault Context

```{.prolog .program}
% fault_context(TID, Context): Context collects
% the exception record of TID, the module of its
% address, its parameters and the thread's last
% error.
fault_context(TID, Context) :-
    exception_record(TID, Code, Addr),
    (   status_name(Code, Name)
    ->  true
    ;   Name = unknown
    ),
    (   address_module(Addr, M)
    ->  true
    ;   M = none
    ),
    findall(K-V, exception_info(TID, K, V), Info),
    (   last_error(TID, E)
    ->  true
    ;   E = unrecorded
    ),
    Context = context(status(Code, Name),
                      address(Addr, M),
                      Info, last_error(E)).
```

```{.prolog .query}
?- fault_context(109, _C), show(_C).
context(status(3221225477,access_violation),
        address(140718380167594,dbclient),
        [access-read,target-24],
        last_error(998))
true.

?- fault_context(111, _C), show(_C).
context(status(3221225620,divide_by_zero),
        address(140718400154432,reportengine),
        [],
        last_error(unrecorded))
true.

?- forall(( exception_record(T, _, A),
            address_module(A, M) ),
          frame(T, 0, M, _, _)).
true.
```

## 19.3 NULL Pointer (Data)

```{.prolog .program}
% access_violation(TID): the exception of TID is
% an access violation.
access_violation(TID) :-
    exception_record(TID, 0xc0000005, _).

% null_pointer_data(TID): TID read or wrote
% through a null pointer.
null_pointer_data(TID) :-
    access_violation(TID),
    exception_info(TID, access, Access),
    Access \== execute,
    exception_info(TID, target, Target),
    threshold(null_page, Limit),
    Target < Limit.

% null_pointer_data(TID, Evidence): as above, with
% the facts the recognition rests on: the record,
% its parameters, and the null page limit.
null_pointer_data(TID, Evidence) :-
    null_pointer_data(TID),
    exception_record(TID, Code, Addr),
    findall(exception_info(TID, K, V),
            exception_info(TID, K, V), Info),
    threshold(null_page, Limit),
    Facts = [exception_record(TID, Code, Addr)
             | Rest],
    append(Info, [threshold(null_page, Limit)],
           Rest),
    Evidence = evidence('NULL Pointer (Data)',
                        TID, Facts).
```

```{.prolog .query}
?- null_pointer_data(T).
T = 109 ;
false.

?- null_pointer_data(109, _E), show(_E).
evidence('NULL Pointer (Data)',
         109,
         [ exception_record(109,
                            3221225477,
                            140718380167594),
           exception_info(109,access,read),
           exception_info(109,target,24),
           threshold(null_page,65536)
         ])
true ;
false.

?- null_pointer_data(T),
   exception_info(T, target, Offset),
   format("field at offset 0x~16r~n", [Offset]).
field at offset 0x18
T = 109,
Offset = 24 ;
false.
```

## 19.4 NULL Pointer (Code)

```{.prolog .program}
% null_pointer_code(TID): TID tried to execute
% code at an address in the null page.
null_pointer_code(TID) :-
    access_violation(TID),
    exception_info(TID, access, execute),
    exception_info(TID, target, Target),
    threshold(null_page, Limit),
    Target < Limit.
```

```{.prolog .query}
?- null_pointer_code(T).
T = 110 ;
false.

?- null_pointer_code(T), print_stack_trace(T).
00 0x0
01 appserver!Plugin::Invoke+0x3c
02 appserver!Worker::Run+0x120
03 ucrtbase!thread_start<...>+0x42
04 kernel32!BaseThreadInitThunk+0x14
05 ntdll!RtlUserThreadStart+0x21
T = 110 ;
false.
```

## 19.5 Invalid Pointer (General)

```{.prolog .program}
% invalid_pointer(TID): TID read or wrote through
% a pointer outside the null page.
invalid_pointer(TID) :-
    access_violation(TID),
    exception_info(TID, access, Access),
    Access \== execute,
    exception_info(TID, target, Target),
    threshold(null_page, Limit),
    Target >= Limit.
```

```{.prolog .query}
?- invalid_pointer(T).
T = 116 ;
false.

?- invalid_pointer(T),
   exception_info(T, target, A),
   format("0x~16r~n", [A]).
0x41414141
T = 116,
A = 1094795585 ;
false.
```

## 19.6 Wild Pointer

```{.prolog .program}
% value_bytes(Value, Bytes): Bytes are the bytes
% of the non-negative integer Value, least
% significant first, without leading zero bytes.
value_bytes(Value, Bytes) :-
    (   Value =:= 0
    ->  Bytes = []
    ;   B is Value /\ 0xff,
        Rest is Value >> 8,
        value_bytes(Rest, Bytes0),
        Bytes = [B | Bytes0]
    ).

% printable(B): byte B is a printable ASCII
% character.
printable(B) :-
    B >= 0x20,
    B =< 0x7e.

% looks_like_text(Value): Value has at least the
% threshold many bytes and all are printable.
looks_like_text(Value) :-
    value_bytes(Value, Bytes),
    threshold(text_bytes, Min),
    length(Bytes, N),
    N >= Min,
    maplist(printable, Bytes).

% wild_pointer(TID): the invalid pointer of TID
% looks like text.
wild_pointer(TID) :-
    invalid_pointer(TID),
    exception_info(TID, target, Target),
    looks_like_text(Target).
```

```{.prolog .query}
?- wild_pointer(T).
T = 116 ;
false.

?- wild_pointer(T), exception_info(T, target, V),
   value_bytes(V, _Bytes),
   format("\"~s\"~n", [_Bytes]).
"AAAA"
T = 116,
V = 1094795585 ;
false.

?- looks_like_text(0x18).
false.

?- looks_like_text(0x7ffb_8d10_31aa).
false.
```

## 19.7 Wild Code

```{.prolog .program}
% wild_code(TID): the exception of TID was raised
% at an address outside the null page and outside
% every module.
wild_code(TID) :-
    exception_record(TID, _, Addr),
    threshold(null_page, Limit),
    Addr >= Limit,
    \+ address_module(Addr, _).
```

```{.prolog .query}
?- wild_code(T).
T = 117 ;
false.

?- wild_code(T), print_stack_trace(T).
00 0x41414141
01 0x41414141
02 0x41414141
03 appserver!Parser::Parse+0x1c4
04 appserver!Worker::Run+0x120
05 ucrtbase!thread_start<...>+0x42
06 kernel32!BaseThreadInitThunk+0x14
07 ntdll!RtlUserThreadStart+0x21
T = 117 ;
false.
```

## 19.8 Local Buffer Overflow (User Space)

```{.prolog .program}
% local_buffer_overflow(TID, Frames): TID has an
% exception and Frames lists the N-Addr pairs of
% its frames below the top whose return address is
% in no module and looks like text.
local_buffer_overflow(TID, Frames) :-
    exception_record(TID, _, _),
    findall(N-Addr,
            ( frame_address(TID, N, Addr),
              N >= 1,
              \+ address_module(Addr, _),
              looks_like_text(Addr)
            ),
            Frames),
    Frames \== [].
```

```{.prolog .query}
?- local_buffer_overflow(T, Fs).
T = 117,
Fs = [1-1094795585, 2-1094795585] ;
false.

?- local_buffer_overflow(T, _), wild_code(T).
T = 117 ;
false.
```

## 19.9 Stack Overflow (User Mode)

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

% frame_key(Frame, Key): Key is the pair
% Module-Function of the frame/5 term Frame.
frame_key(frame(_, _, M, F, _), M-F).

% stack_trace_signature(TID, Signature): the keys
% of the frames of TID, top frame first.
stack_trace_signature(TID, Signature) :-
    stack_trace(TID, Frames),
    maplist(frame_key, Frames, Signature).

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

% stack_depth(TID, Depth): the stack trace of TID
% has Depth frames.
stack_depth(TID, Depth) :-
    stack_trace(TID, Frames),
    length(Frames, Depth).

% stack_overflow(TID, Finding): Finding is the
% evidence that TID overflowed its stack, by the
% status code, or the suspicion of it, by depth
% and a run at least overflow_run long.
stack_overflow(TID, Finding) :-
    exception_record(TID, 0xc00000fd, Addr),
    Name = 'Stack Overflow (User Mode)',
    Code = 0xc00000fd,
    Facts = [exception_record(TID, Code, Addr)],
    Finding = evidence(Name, TID, Facts).
stack_overflow(TID, Finding) :-
    thread(TID, PID),
    stack_depth(TID, Depth),
    threshold(stack_depth, MinDepth),
    Depth >= MinDepth,
    frame_regularity(TID, Key, Count),
    threshold(overflow_run, MinRun),
    Count >= MinRun,
    Name = 'Stack Overflow (User Mode)',
    Grounds = [ thread(TID, PID),
                stack_depth(TID, Depth),
                threshold(stack_depth, MinDepth),
                frame_regularity(TID, Key, Count),
                threshold(overflow_run, MinRun)
              ],
    Finding = suspected(Name, TID, Grounds).
```

```{.prolog .query}
?- stack_overflow(T, _F), functor(_F, Form, 3),
   format("~a ~d~n", [Form, T]), fail.
evidence 119
suspected 107
suspected 119
false.

?- stack_overflow(T, evidence(_, _, _Fs)),
   forall(member(F, _Fs), ( print(F), nl )).
exception_record(119,3221225725,140718400126994)
T = 119 ;
false.

?- stack_overflow(T, suspected(_, T, _Gs)),
   forall(member(G, _Gs), ( print(G), nl )),
   nl, fail.
thread(107,4120)
stack_depth(107,14)
threshold(stack_depth,12)
frame_regularity(107,reportengine-'Node::Visit',8)
threshold(overflow_run,6)

thread(119,4120)
stack_depth(119,13)
threshold(stack_depth,12)
frame_regularity(119,reportengine-'Node::Visit',7)
threshold(overflow_run,6)

false.
```

```{.prolog .query}
?- stack_overflow(T, evidence(_, _, _Fs)),
   ground(_Fs), maplist(call, _Fs),
   memberchk(exception_record(T, 0xc00000fd, _),
             _Fs).
T = 119 ;
false.

?- stack_overflow(T, suspected(_, _, _Gs)),
   ground(_Gs), maplist(call, _Gs),
   memberchk(stack_depth(T, D), _Gs),
   memberchk(threshold(stack_depth, MinD), _Gs),
   memberchk(frame_regularity(T, _, C), _Gs),
   memberchk(threshold(overflow_run, MinC), _Gs),
   D >= MinD, C >= MinC.
T = 107,
D = 14,
MinD = 12,
C = 8,
MinC = 6 ;
T = 119,
D = 13,
MinD = 12,
C = 7,
MinC = 6 ;
false.
```

### 19.9.1 The Two Run Thresholds

```{.prolog .program}
% synthetic_stack(TID, Functions): add thread TID
% to the process with one frame per function of
% Functions, top frame first, all in appserver.
synthetic_stack(TID, Functions) :-
    assertz(thread(TID, 4120)),
    forall(nth0(N, Functions, F),
           assertz(frame(TID, N, appserver, F,
                         0x10))).

% run_report(TID): the depth of TID, the runs that
% reach frame_run, and the forms of its findings.
run_report(TID) :-
    stack_depth(TID, Depth),
    findall(C, frame_regularity(TID, _, C), Runs),
    findall(Form,
            ( stack_overflow(TID, F),
              functor(F, Form, 3)
            ),
            Forms),
    format("~d depth ~d runs ~w ~w~n",
           [TID, Depth, Runs, Forms]).
```

```{.prolog .query}
?- synthetic_stack(140,
       [f, f, f, f, g, h, i, j, k, l, m, n]),
   synthetic_stack(141,
       [f, f, f, f, f, g, h, i, j, k, l, m]),
   synthetic_stack(142,
       [f, f, f, f, f, f, g, h, i, j, k, l]),
   synthetic_stack(143, [f, f, f, f, f, f, g, h]),
   synthetic_stack(144, [a, b, c]),
   assertz(exception_record(144, 0xc00000fd,
                            0x7ff6_1d11_0010)).
true.

?- threshold(frame_run, R),
   threshold(overflow_run, O).
R = 4,
O = 6.

?- forall(member(T, [107, 119, 140, 141, 142,
                    143, 144]),
          run_report(T)).
107 depth 14 runs [8] [suspected]
119 depth 13 runs [7] [evidence,suspected]
140 depth 12 runs [4] []
141 depth 12 runs [5] []
142 depth 12 runs [6] [suspected]
143 depth 8 runs [6] []
144 depth 3 runs [] [evidence]
true.

?- stack_overflow(T, suspected(_, _, _)),
   T >= 140.
T = 142 ;
false.
```

```{.prolog .query}
?- forall(between(140, 144, T),
          ( retractall(thread(T, _)),
            retractall(frame(T, _, _, _, _)),
            retractall(exception_record(T, _, _))
          )),
   aggregate_all(count, thread(_, _), N),
   aggregate_all(count,
                 exception_record(_, _, _), E).
N = 19,
E = 9.
```

## 19.10 Divide by Zero (User Mode)

```{.prolog .program}
% divide_by_zero(TID): TID divided an integer by
% zero.
divide_by_zero(TID) :-
    exception_record(TID, 0xc0000094, _).
```

```{.prolog .query}
?- divide_by_zero(T), print_stack_trace(T).
00 reportengine!Stats::Mean+0x40
01 reportengine!Report::Summarize+0x88
02 appserver!Worker::Run+0x120
03 ucrtbase!thread_start<...>+0x42
04 kernel32!BaseThreadInitThunk+0x14
05 ntdll!RtlUserThreadStart+0x21
T = 111.
```

## 19.11 Nested Exceptions (User Space)

```{.prolog .program}
% dispatch_frame(TID, N): frame N of TID is the
% user-mode exception dispatcher.
dispatch_frame(TID, N) :-
    frame(TID, N, ntdll, F, _),
    F == 'KiUserExceptionDispatch'.

% nested_exceptions(TID): the exception of TID was
% raised while an earlier exception of TID was
% being dispatched.
nested_exceptions(TID) :-
    exception_record(TID, _, Addr),
    dispatch_frame(TID, N),
    N > 0,
    frame(TID, 0, M, _, _),
    address_module(Addr, M).
```

```{.prolog .query}
?- nested_exceptions(T), print_stack_trace(T).
00 kernelbase!RaiseException+0x6e
01 vcruntime140!_CxxThrowException+0x90
02 appserver!Handler::Report+0x66
03 appserver!Handler::OnFault+0x2e
04 ntdll!RtlpExecuteHandlerForException+0xf
05 ntdll!RtlDispatchException+0x244
06 ntdll!KiUserExceptionDispatch+0x2e
07 dbclient!Buffer::Copy+0x1a
08 dbclient!Connection::Receive+0x8c
09 appserver!Session::Fetch+0x44
10 appserver!Worker::Run+0x120
11 ucrtbase!thread_start<...>+0x42
12 kernel32!BaseThreadInitThunk+0x14
13 ntdll!RtlUserThreadStart+0x21
T = 114 ;
false.
```

## 19.12 Multiple Exceptions (User Space)

```{.prolog .program}
% multiple_exceptions(TIDs): more than one thread
% has an exception record; TIDs lists them.
multiple_exceptions(TIDs) :-
    findall(TID, exception_record(TID, _, _),
            TIDs),
    length(TIDs, Count),
    Count > 1.
```

```{.prolog .query}
?- multiple_exceptions(_TIDs), length(_TIDs, N).
N = 9.

?- findall(T,
       ( exception_record(T, _, _), T =< 109 ),
   Ts), length(Ts, N).
Ts = [109],
N = 1.
```

## 19.13 Hidden Exception (User Space)

```{.prolog .program}
% exception_frame(F): F is a function that raises
% or dispatches an exception.
exception_frame('KiUserExceptionDispatch').
exception_frame('RaiseException').

% hidden_exception(TID, N): TID has no exception
% record and frame N of its trace is an exception
% frame.
hidden_exception(TID, N) :-
    thread(TID, _),
    \+ exception_record(TID, _, _),
    frame(TID, N, _, F, _),
    exception_frame(F).
```

```{.prolog .query}
?- hidden_exception(T, N).
T = 115,
N = 6 ;
false.

?- hidden_exception(T, _), print_stack_trace(T).
00 ntdll!NtWaitForSingleObject+0x14
01 kernelbase!WaitForSingleObjectEx+0x8e
02 appserver!Logger::Flush+0x72
03 appserver!Handler::OnFault+0x4a
04 ntdll!RtlpExecuteHandlerForException+0xf
05 ntdll!RtlDispatchException+0x244
06 ntdll!KiUserExceptionDispatch+0x2e
07 appserver!Session::Parse+0xb0
08 appserver!Worker::Run+0x120
09 ucrtbase!thread_start<...>+0x42
10 kernel32!BaseThreadInitThunk+0x14
11 ntdll!RtlUserThreadStart+0x21
T = 115 ;
false.
```

## 19.14 Handled Exception (User Space)

```{.prolog .program}
% handled_exception(TID, Handler): the dispatcher
% on the stack of TID has called a handler, whose
% Module-Function is Handler.
handled_exception(TID, Handler) :-
    dispatch_frame(TID, N),
    aggregate_all(max(H),
                  ( frame(TID, H, M, _, _),
                    H < N,
                    module(M, _, _),
                    \+ system_module(M)
                  ),
                  Top),
    frame(TID, Top, HM, HF, _),
    Handler = HM-HF.
```

```{.prolog .query}
?- handled_exception(T, H).
T = 114,
H = appserver-'Handler::OnFault' ;
T = 115,
H = appserver-'Handler::OnFault' ;
false.

?- handled_exception(T, _),
   hidden_exception(T, _).
T = 115 ;
false.

?- handled_exception(T, _), nested_exceptions(T).
T = 114 ;
false.
```

## 19.15 C++ Exception

```{.prolog .program}
% cpp_exception(TID): TID raised a C++ exception.
cpp_exception(TID) :-
    exception_record(TID, 0xe06d7363, _).
```

```{.prolog .query}
?- cpp_exception(T).
T = 112 ;
T = 114.

?- cpp_exception(112), print_stack_trace(112).
00 kernelbase!RaiseException+0x6e
01 vcruntime140!_CxxThrowException+0x90
02 appserver!Parser::Expect+0x5a
03 appserver!Parser::Parse+0x1c4
04 appserver!Worker::Run+0x120
05 ucrtbase!thread_start<...>+0x42
06 kernel32!BaseThreadInitThunk+0x14
07 ntdll!RtlUserThreadStart+0x21
true ;
false.
```

## 19.16 Managed Code Exception

```{.prolog .program}
% managed_code_exception(TID): TID raised a .NET
% runtime exception.
managed_code_exception(TID) :-
    exception_record(TID, 0xe0434352, _).
```

```{.prolog .query}
?- managed_code_exception(T),
   print_stack_trace(T).
00 kernelbase!RaiseException+0x6e
01 coreclr!RaiseTheExceptionInternalOnly+0x2a8
02 coreclr!IL_Throw+0x1c0
03 <no module>
04 kernel32!BaseThreadInitThunk+0x14
05 ntdll!RtlUserThreadStart+0x21
T = 113.
```

## 19.17 Stored Exception

```{.prolog .program}
% past_exception(TID, Code, Addr): a stored record
% of TID describes an exception that is not its
% current one.
past_exception(TID, Code, Addr) :-
    stored_exception(TID, _, Code, Addr),
    \+ exception_record(TID, Code, Addr).
```

```{.prolog .query}
?- stored_exception(T, _, C, A),
   format("~d ~16r at ~16r~n", [T, C, A]), fail.
109 c0000005 at 7ffb8d1031aa
115 c0000005 at 7ff61d11b0c8
false.

?- past_exception(T, C, A), address_module(A, M).
T = 115,
C = 3221225477,
A = 140695026381000,
M = appserver ;
false.

?- past_exception(115, _, A),
   address_module(A, M), module(M, _Base, _),
   Off is A - _Base,
   format("~a+0x~16r~n", [M, Off]).
appserver+0x1b0c8
A = 140695026381000,
M = appserver,
Off = 110792 ;
false.
```

## 19.18 Exception Module

```{.prolog .program}
% exception_module(TID, Module): the exception of
% TID was raised in Module, or in none.
exception_module(TID, Module) :-
    exception_record(TID, _, Addr),
    (   address_module(Addr, M)
    ->  Module = M
    ;   Module = none
    ).
```

```{.prolog .query}
?- exception_module(109, M).
M = dbclient.

?- exception_module(T, kernelbase).
T = 112 ;
T = 113 ;
T = 114 ;
false.

?- exception_module(T, none).
T = 110 ;
T = 117 ;
false.
```

## 19.19 Problem Module

```{.prolog .program}
% problem_frame(TID, Frame): Frame is the topmost
% frame of TID in a module that is not a system
% module.
problem_frame(TID, frame(TID, N, M, F, O)) :-
    exception_record(TID, _, _),
    aggregate_all(min(N0),
                  ( frame(TID, N0, M0, _, _),
                    module(M0, _, _),
                    \+ system_module(M0)
                  ),
                  N),
    frame(TID, N, M, F, O).

% problem_module(TID, Module): Module is the
% module of the problem frame of TID.
problem_module(TID, Module) :-
    problem_frame(TID, frame(_, _, Module, _, _)).
```

```{.prolog .query}
?- problem_module(T, M), exception_module(T, EM),
   M \== EM.
T = 110,
M = appserver,
EM = none ;
T = 112,
M = appserver,
EM = kernelbase ;
T = 114,
M = appserver,
EM = kernelbase ;
T = 117,
M = appserver,
EM = none ;
false.

?- problem_module(113, M).
false.

?- problem_module(109, M),
   module_info(M, company, C),
   module_info(M, version, V).
M = dbclient,
C = 'Example Corp',
V = '3.1.0.7' ;
false.
```

## 19.20 Crash Signature

```{.prolog .program}
% crash_signature(TID, Signature): Signature is
% the canonical term sig(Kind, Module, Function,
% Offset) of the fault of TID.
crash_signature(TID, sig(Kind, M, F, O)) :-
    exception_record(TID, Code, _),
    (   status_name(Code, Kind)
    ->  true
    ;   Kind = Code
    ),
    (   problem_frame(TID, frame(_, _, M, F, O))
    ->  true
    ;   M = none,
        F = 'Unknown',
        O = 0
    ).

% print_signature(TID): the signature of TID in
% the debugger's notation.
print_signature(TID) :-
    crash_signature(TID, sig(Kind, M, F, O)),
    format("~d ~a ~a!~a+0x~16r~n",
           [TID, Kind, M, F, O]).
```

```{.prolog .query}
?- crash_signature(109, sig(K, M, F, O)).
K = access_violation,
M = dbclient,
F = 'Buffer::Copy',
O = 26.

?- forall(exception_record(T, _, _),
          print_signature(T)).
109 access_violation dbclient!Buffer::Copy+0x1a
110 access_violation appserver!Plugin::Invoke+0x3c
111 divide_by_zero reportengine!Stats::Mean+0x40
112 cpp_exception appserver!Parser::Expect+0x5a
113 clr_exception none!Unknown+0x0
114 cpp_exception appserver!Handler::Report+0x66
116 access_violation dbclient!Row::Get+0x32
117 access_violation appserver!Parser::Parse+0x1c4
119 stack_overflow reportengine!Node::Visit+0x12
true.

?- crash_signature(109, _S),
   crash_signature(T, _S), T \== 109.
false.
```

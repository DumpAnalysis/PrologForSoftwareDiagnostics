# Appendix B. The Shared Artifacts

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/B-shared-artifacts.md`.

## B.1 dump1.pl

```{.prolog .program .small file=dump1.pl}
% dump1.pl -- a synthetic user-space process memory dump
% rendered as Prolog facts.  Used throughout the book.
%
% The data is modelled on what a Windows debugger shows
% for a 64-bit process, but every value is invented.

:- discontiguous frame/5.

% process(PID, Name)
process(4120, 'AppServer.exe').

% module(Name, Base, Size)
module(ntdll, 0x7ffb_b2a0_0000, 0x1f8000).
module(kernelbase, 0x7ffb_b0b0_0000, 0x2f1000).
module(kernel32, 0x7ffb_b1c0_0000, 0xbd000).
module(ucrtbase, 0x7ffb_ae50_0000, 0x100000).
module(msvcp140, 0x7ffb_9c20_0000, 0x9f000).
module(appserver, 0x7ff6_1d10_0000, 0x3c000).
module(reportengine, 0x7ffb_8e40_0000, 0x1a2000).
module(dbclient, 0x7ffb_8d10_0000, 0x6e000).
module(cachelib, 0x7ffb_7a00_0000, 0x4a000).
module(thirdparty_hook,0x7ffb_6f30_0000, 0x12000).

% module_info(Name, Key, Value)
module_info(appserver, version, '3.2.1.0').
module_info(reportengine, version, '3.2.1.0').
module_info(dbclient, version, '3.1.0.7').
module_info(cachelib, version, '2.0.0.0').
module_info(thirdparty_hook, version, '1.0.0.1').
module_info(ntdll, symbols, pdb).
module_info(kernelbase, symbols, pdb).
module_info(kernel32, symbols, pdb).
module_info(ucrtbase, symbols, pdb).
module_info(msvcp140, symbols, pdb).
module_info(appserver, symbols, pdb).
module_info(reportengine, symbols, pdb).
module_info(dbclient, symbols, export).
module_info(cachelib, symbols, none).
module_info(thirdparty_hook, symbols, none).
module_info(thirdparty_hook, company, 'Unknown').
module_info(appserver, company, 'Example Corp').
module_info(reportengine, company, 'Example Corp').
module_info(dbclient, company, 'Example Corp').
module_info(cachelib, company, 'CacheWorks').

% thread(TID, PID)
thread(100, 4120).
thread(101, 4120).
thread(102, 4120).
thread(103, 4120).
thread(104, 4120).
thread(105, 4120).
thread(106, 4120).
thread(107, 4120).
thread(108, 4120).
thread(109, 4120).

% thread_time(TID, UserMs, KernelMs)
thread_time(100, 120, 40).
thread_time(101, 15, 5).
thread_time(102, 8450, 1230).
thread_time(103, 30, 10).
thread_time(104, 25, 10).
thread_time(105, 20, 5).
thread_time(106, 10, 5).
thread_time(107, 3200, 900).
thread_time(108, 0, 0).
thread_time(109, 40, 20).

% thread_state(TID, State)
thread_state(100, waiting(user_request)).
thread_state(101, waiting(user_request)).
thread_state(102, running).
thread_state(103, waiting(user_request)).
thread_state(104, waiting(user_request)).
thread_state(105, waiting(user_request)).
thread_state(106, waiting(user_request)).
thread_state(107, running).
thread_state(108, suspended).
thread_state(109, waiting(exception)).

% frame(TID, N, Module, Function, Offset)
% thread 100: main thread, waiting in the message loop
frame(100, 0, ntdll, 'NtWaitForMultipleObjects', 0x14).
frame(100, 1, kernelbase, 'WaitForMultipleObjectsEx', 0xe9).
frame(100, 2, appserver, 'MainLoop', 0x1b2).
frame(100, 3, appserver, 'wmain', 0x55).
frame(100, 4, appserver, 'invoke_main', 0x22).
frame(100, 5, kernel32, 'BaseThreadInitThunk', 0x14).
frame(100, 6, ntdll, 'RtlUserThreadStart', 0x21).

% thread 101: worker blocked on a critical section
frame(101, 0, ntdll, 'NtWaitForAlertByThreadId', 0x14).
frame(101, 1, ntdll, 'RtlpWaitOnCriticalSection',0x1cf).
frame(101, 2, ntdll, 'RtlpEnterCriticalSectionContended',
      0x1cd).
frame(101, 3, ntdll, 'RtlEnterCriticalSection', 0x40).
frame(101, 4, cachelib, 'Unknown', 0x2a10).
frame(101, 5, appserver, 'Session::Lookup', 0x7c).
frame(101, 6, appserver, 'Worker::Run', 0x120).
frame(101, 7, ucrtbase, 'thread_start<...>', 0x42).
frame(101, 8, kernel32, 'BaseThreadInitThunk', 0x14).
frame(101, 9, ntdll, 'RtlUserThreadStart', 0x21).

% thread 102: spiking thread, busy in a tight loop
frame(102, 0, reportengine, 'Table::Find', 0x3e).
frame(102, 1, reportengine, 'Table::Insert', 0x9a).
frame(102, 2, reportengine, 'Report::Build', 0x214).
frame(102, 3, appserver, 'Worker::Run', 0x120).
frame(102, 4, ucrtbase, 'thread_start<...>', 0x42).
frame(102, 5, kernel32, 'BaseThreadInitThunk', 0x14).
frame(102, 6, ntdll, 'RtlUserThreadStart', 0x21).

% thread 103: owner of CS A, waiting for CS B (deadlock half)
frame(103, 0, ntdll, 'NtWaitForAlertByThreadId', 0x14).
frame(103, 1, ntdll, 'RtlpWaitOnCriticalSection',0x1cf).
frame(103, 2, ntdll, 'RtlpEnterCriticalSectionContended',
      0x1cd).
frame(103, 3, ntdll, 'RtlEnterCriticalSection', 0x40).
frame(103, 4, dbclient, 'Connection::Send', 0x58).
frame(103, 5, appserver, 'Session::Commit', 0x9e).
frame(103, 6, appserver, 'Worker::Run', 0x120).
frame(103, 7, ucrtbase, 'thread_start<...>', 0x42).
frame(103, 8, kernel32, 'BaseThreadInitThunk', 0x14).
frame(103, 9, ntdll, 'RtlUserThreadStart', 0x21).

% thread 104: owner of CS B, waiting for CS A (deadlock half)
frame(104, 0, ntdll, 'NtWaitForAlertByThreadId', 0x14).
frame(104, 1, ntdll, 'RtlpWaitOnCriticalSection',0x1cf).
frame(104, 2, ntdll, 'RtlpEnterCriticalSectionContended',
      0x1cd).
frame(104, 3, ntdll, 'RtlEnterCriticalSection', 0x40).
frame(104, 4, appserver, 'Session::Lookup', 0x7c).
frame(104, 5, dbclient, 'Connection::OnReply', 0x1f).
frame(104, 6, dbclient, 'Reader::Loop', 0xa4).
frame(104, 7, ucrtbase, 'thread_start<...>', 0x42).
frame(104, 8, kernel32, 'BaseThreadInitThunk', 0x14).
frame(104, 9, ntdll, 'RtlUserThreadStart', 0x21).

% thread 105: thread pool, idle
frame(105, 0, ntdll, 'NtWaitForWorkViaWorkerFactory', 0x14).
frame(105, 1, ntdll, 'TppWorkerThread', 0x2df).
frame(105, 2, kernel32, 'BaseThreadInitThunk', 0x14).
frame(105, 3, ntdll, 'RtlUserThreadStart', 0x21).

% thread 106: thread pool, idle
frame(106, 0, ntdll, 'NtWaitForWorkViaWorkerFactory', 0x14).
frame(106, 1, ntdll, 'TppWorkerThread', 0x2df).
frame(106, 2, kernel32, 'BaseThreadInitThunk', 0x14).
frame(106, 3, ntdll, 'RtlUserThreadStart', 0x21).

% thread 107: deep recursion (stack overflow candidate)
frame(107, 0, reportengine, 'Node::Visit', 0x12).
frame(107, 1, reportengine, 'Node::Visit', 0x6b).
frame(107, 2, reportengine, 'Node::Visit', 0x6b).
frame(107, 3, reportengine, 'Node::Visit', 0x6b).
frame(107, 4, reportengine, 'Node::Visit', 0x6b).
frame(107, 5, reportengine, 'Node::Visit', 0x6b).
frame(107, 6, reportengine, 'Node::Visit', 0x6b).
frame(107, 7, reportengine, 'Node::Visit', 0x6b).
frame(107, 8, reportengine, 'Tree::Walk', 0x30).
frame(107, 9, reportengine, 'Report::Build', 0x1f0).
frame(107, 10, appserver, 'Worker::Run', 0x120).
frame(107, 11, ucrtbase, 'thread_start<...>', 0x42).
frame(107, 12, kernel32, 'BaseThreadInitThunk', 0x14).
frame(107, 13, ntdll, 'RtlUserThreadStart', 0x21).

% thread 108: suspended, no meaningful frames
frame(108, 0, ntdll, 'NtDelayExecution', 0x14).
frame(108, 1, kernelbase, 'SleepEx', 0x9e).
frame(108, 2, appserver, 'Housekeeping::Run', 0x3a).
frame(108, 3, kernel32, 'BaseThreadInitThunk', 0x14).
frame(108, 4, ntdll, 'RtlUserThreadStart', 0x21).

% thread 109: the faulting thread
frame(109, 0, dbclient, 'Buffer::Copy', 0x1a).
frame(109, 1, dbclient, 'Connection::Receive', 0x8c).
frame(109, 2, appserver, 'Session::Fetch', 0x44).
frame(109, 3, appserver, 'Worker::Run', 0x120).
frame(109, 4, ucrtbase, 'thread_start<...>', 0x42).
frame(109, 5, kernel32, 'BaseThreadInitThunk', 0x14).
frame(109, 6, ntdll, 'RtlUserThreadStart', 0x21).

% exception_record(TID, Code, Address)
exception_record(109, 0xc0000005, 0x7ffb_8d10_31aa).

% exception_info(TID, Key, Value)
exception_info(109, access, read).
exception_info(109, target, 0x0000_0000_0000_0018).

% critical_section(Addr, OwnerTID, WaiterCount, RecursionCount)
critical_section(0x7ff6_1d13_a0c0, 103, 2, 1).
critical_section(0x7ff6_1d13_a140, 104, 1, 1).
critical_section(0x7ff6_1d13_a1c0, 0, 0, 0).

% waits_for(TID, Kind, Addr)
waits_for(101, critical_section, 0x7ff6_1d13_a0c0).
waits_for(103, critical_section, 0x7ff6_1d13_a140).
waits_for(104, critical_section, 0x7ff6_1d13_a0c0).

% handle_count(PID, Type, Count)
handle_count(4120, event, 12040).
handle_count(4120, file, 38).
handle_count(4120, thread, 10).
handle_count(4120, mutant, 4).
handle_count(4120, section, 6).
handle_count(4120, key, 14).

% heap(HeapAddr, ReservedKb, CommittedKb, FreeKb)
heap(0x0000_0210_a000_0000, 2097152, 1835008, 24576).
heap(0x0000_0210_a001_0000, 1024, 256, 128).
heap(0x0000_0210_a200_0000, 65536, 61440, 1024).

% last_error(TID, Code)
last_error(100, 0).
last_error(101, 0).
last_error(102, 0).
last_error(103, 0).
last_error(104, 0).
last_error(109, 0x3e6).   % ERROR_NOACCESS

% hooked(Function, Module, Hooker)
hooked('CreateFileW', kernelbase, thirdparty_hook).
hooked('ReadFile', kernelbase, thirdparty_hook).
```

## B.2 trace1.pl

```{.prolog .program .small file=trace1.pl}
% trace1.pl -- a synthetic software trace.
% Used throughout the book. Values are invented.
%
% msg(N, Time, PID, TID, Component, Text)
%   N          message number (1-based)
%   Time       seconds from trace start (float)
%   PID, TID   process and thread identifiers
%   Component  atom naming the source component
%   Text       the message text (a string)

msg(1,  0.000, 4120, 100, appserver,
    "Service starting, version 3.2.1.0").
msg(2,  0.004, 4120, 100, appserver,
    "Loading configuration C:\\App\\app.cfg").
msg(3,  0.011, 4120, 100, cachelib,
    "Cache initialized, capacity=4096").
msg(4,  0.015, 4120, 100, dbclient,
    "Connecting to db01:5432").
msg(5,  0.212, 4120, 100, dbclient,
    "Connected to db01:5432, session=71").
msg(6,  0.214, 4120, 100, appserver,
    "Worker pool started, threads=4").
msg(7,  0.215, 4120, 101, appserver,
    "Worker 101 ready").
msg(8,  0.215, 4120, 102, appserver,
    "Worker 102 ready").
msg(9,  0.216, 4120, 103, appserver,
    "Worker 103 ready").
msg(10, 0.216, 4120, 104, appserver,
    "Worker 104 ready").
msg(11, 1.002, 4120, 100, appserver,
    "Request 1 received: GET /report/17").
msg(12, 1.003, 4120, 101, appserver,
    "Request 1 dispatched to worker 101").
msg(13, 1.004, 4120, 101, dbclient,
    "Query start: SELECT report 17").
msg(14, 1.048, 4120, 101, dbclient,
    "Query end: 1 row, 44 ms").
msg(15, 1.049, 4120, 101, reportengine,
    "Build start: report 17").
msg(16, 1.310, 4120, 101, reportengine,
    "Build end: report 17, 2611 nodes, 261 ms").
msg(17, 1.311, 4120, 101, appserver,
    "Request 1 completed: 200, 309 ms").
msg(18, 1.500, 4120, 100, appserver,
    "Request 2 received: GET /report/18").
msg(19, 1.501, 4120, 102, appserver,
    "Request 2 dispatched to worker 102").
msg(20, 1.502, 4120, 102, dbclient,
    "Query start: SELECT report 18").
msg(21, 1.550, 4120, 102, dbclient,
    "Query end: 1 row, 48 ms").
msg(22, 1.551, 4120, 102, reportengine,
    "Build start: report 18").
msg(23, 2.000, 4120, 100, appserver,
    "Request 3 received: POST /session/commit").
msg(24, 2.001, 4120, 103, appserver,
    "Request 3 dispatched to worker 103").
msg(25, 2.002, 4120, 103, appserver,
    "Session 9 commit start").
msg(26, 2.003, 4120, 103, dbclient,
    "Send start: session=71, bytes=1024").
msg(27, 2.100, 4120, 100, appserver,
    "Request 4 received: GET /session/9").
msg(28, 2.101, 4120, 104, appserver,
    "Request 4 dispatched to worker 104").
msg(29, 2.102, 4120, 104, dbclient,
    "Reply received: session=71, bytes=512").
msg(30, 2.103, 4120, 104, appserver,
    "Session 9 lookup start").
msg(31, 2.500, 4120, 102, reportengine,
    "Warning: table resize, 8192 -> 16384").
msg(32, 3.000, 4120, 102, reportengine,
    "Warning: table resize, 16384 -> 32768").
msg(33, 3.500, 4120, 102, reportengine,
    "Warning: table resize, 32768 -> 65536").
msg(34, 4.000, 4120, 102, reportengine,
    "Warning: table resize, 65536 -> 131072").
msg(35, 4.500, 4120, 102, reportengine,
    "Warning: table resize, 131072 -> 262144").
msg(36, 5.000, 4120, 102, reportengine,
    "Warning: table resize, 262144 -> 524288").
msg(37, 5.001, 4120, 100, appserver,
    "Request 5 received: GET /report/19").
msg(38, 5.002, 4120, 100, appserver,
    "No idle worker, request 5 queued").
msg(39, 6.000, 4120, 100, appserver,
    "Request 6 received: GET /health").
msg(40, 6.001, 4120, 100, appserver,
    "No idle worker, request 6 queued").
msg(41, 7.000, 4120, 100, appserver,
    "Request 7 received: GET /health").
msg(42, 7.001, 4120, 100, appserver,
    "No idle worker, request 7 queued").
msg(43, 7.002, 4120, 100, appserver,
    "Error: queue depth 3 exceeds threshold 2").
msg(44, 8.000, 4120, 100, appserver,
    "Request 8 received: GET /health").
msg(45, 8.001, 4120, 100, appserver,
    "Error: queue depth 4 exceeds threshold 2").
msg(46, 9.000, 4120, 100, appserver,
    "Request 9 received: GET /health").
msg(47, 9.001, 4120, 100, appserver,
    "Error: queue depth 5 exceeds threshold 2").
msg(48, 9.002, 4120, 108, appserver,
    "Housekeeping: watchdog, workers busy=4").
msg(49, 9.003, 4120, 108, appserver,
    "Housekeeping: worker 103 wait 7001 ms").
msg(50, 9.003, 4120, 108, appserver,
    "Housekeeping: worker 104 wait 6900 ms").
msg(51, 9.004, 4120, 108, appserver,
    "Housekeeping: worker 102 cpu 100%").
msg(52, 9.005, 4120, 108, appserver,
    "Housekeeping: worker 101 idle").
msg(53, 9.006, 4120, 101, appserver,
    "Request 5 dispatched to worker 101").
msg(54, 9.007, 4120, 101, dbclient,
    "Query start: SELECT report 19").
msg(55, 9.060, 4120, 101, dbclient,
    "Query end: 1 row, 53 ms").
msg(56, 9.061, 4120, 101, reportengine,
    "Build start: report 19").
msg(57, 9.300, 4120, 101, reportengine,
    "Build end: report 19, 2402 nodes, 239 ms").
msg(58, 9.301, 4120, 101, appserver,
    "Request 5 completed: 200, 4300 ms").
msg(59, 9.302, 4120, 101, appserver,
    "Request 6 dispatched to worker 101").
msg(60, 9.303, 4120, 101, appserver,
    "Request 6 completed: 200, 3302 ms").
msg(61, 9.304, 4120, 101, appserver,
    "Request 7 dispatched to worker 101").
msg(62, 9.305, 4120, 101, appserver,
    "Request 7 completed: 200, 2305 ms").
msg(63, 9.306, 4120, 101, appserver,
    "Request 8 dispatched to worker 101").
msg(64, 9.307, 4120, 101, appserver,
    "Request 8 completed: 200, 1307 ms").
msg(65, 9.308, 4120, 101, appserver,
    "Request 9 dispatched to worker 101").
msg(66, 9.309, 4120, 101, appserver,
    "Request 9 completed: 200, 309 ms").
msg(67, 14.000, 4120, 109, appserver,
    "Request 10 received: GET /session/9/data").
msg(68, 14.001, 4120, 109, dbclient,
    "Receive start: session=71").
msg(69, 14.002, 4120, 109, dbclient,
    "Error: buffer copy failed, code=0x3e6").
msg(70, 14.003, 4120, 109, appserver,
    "Unhandled exception 0xc0000005, thread 109").
msg(71, 14.010, 4120, 100, appserver,
    "Service stopping").
```

```{.prolog .query}
?- aggregate_all(count, frame(_, _, _, _, _), F),
   aggregate_all(count, msg(_, _, _, _, _, _), M).
F = 78,
M = 71.
```

## B.3 patterns_dump.pl

```{.prolog .program .small file=patterns_dump.pl}
% patterns_dump.pl -- the recognizers of Chapters 18 to 22
% that the report of Chapter 23 composes, collected in one
% module with the clauses of those chapters.
%
% The module does not consult dump1.pl: a file without a
% module declaration is loaded into one module only
% (Chapter 13), and the chapters load the dump into user.
% Every reference to a relation of the dump schema is
% therefore qualified with user:, and the module is loaded
% after the dump with :- use_module(patterns_dump).
%
% The thresholds and the analyst's list of system modules
% are facts of this module, exported, multifile and dynamic,
% so that a chapter can add a clause or change a value.
% The extension relations that Chapters 20 and 21 define
% in-chapter are declared dynamic in user, so that a
% knowledge base without them fails rather than raising an
% existence error.
%
% Every predicate that can appear as a leaf of an evidence
% or suspicion term is exported, so that the leaves are
% callable, unqualified, from any module that imports this
% one (Section 17.3). The last group of exports checks that
% contract: derivable/2 and sufficient/1 re-derive a finding
% from its own leaves, and check_explainers/0 runs every
% explainer of explainer/2 on the loaded knowledge base and
% calls the leaves in the module that calls it. The
% derivation has a closed vocabulary: dump_relation/1 names
% the relations it takes from the evidence list only, and
% evaluable/1 the first-order built-ins it calls; every
% other goal is interpreted, expanded through its clauses,
% or rejected with a domain error.

:- module(patterns_dump,
          [ threshold/2,
            system_module/1,
            % Chapter 18
            stack_trace/2,
            stack_trace_signature/2,
            runs/2,
            main_thread/1,
            cpu_time/2,
            total_cpu/1,
            cpu_share/2,
            spiking_thread/1,
            spiking_thread/2,
            blocked_thread/1,
            blocked_thread/2,
            frame_regularity/3,
            % Chapters 1 and 23
            suspended_thread/1,
            % Chapter 19
            exception_stack_trace/2,
            null_pointer_data/1,
            null_pointer_data/2,
            stack_depth/2,
            stack_overflow/2,
            % Chapter 20
            waits/3,
            wait_edge/3,
            wait_edge/4,
            edge_of/3,
            edge_of/4,
            wait_chain/2,
            deadlock_witness/3,
            cycle_kinds/2,
            deadlock/2,
            deadlock/3,
            % Chapter 21
            insufficient_memory/2,
            insufficient_memory/3,
            handle_leak/1,
            memory_leak/1,
            % Chapter 22
            main_module/1,
            vendor/2,
            not_my_version/1,
            unknown_component/1,
            no_component_symbols/1,
            hooked_functions/3,
            last_error_collection/1,
            % Chapters 17 and 23: the evidence contract
            explainer/2,
            dump_relation/1,
            evaluable/1,
            derivable/2,
            sufficient/1,
            check_finding/3,
            check_explainers/0
          ]).

:- multifile threshold/2, system_module/1.
:- dynamic threshold/2, system_module/1.

% The library predicates the module uses are imported
% by name, so that a definition of the same name in
% user, the module's default import module, cannot
% stand in for them (Chapter 13).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(pairs)).
:- use_module(library(aggregate)).
:- use_module(library(error)).

:- dynamic user:mutant/3, user:waits_for_object/3.
:- dynamic user:heap_at/5, user:dump_time/2.

% threshold(Name, Value): the thresholds of Chapters 18 to
% 21, as those chapters state them. frame_run is the run
% length of a Frame Regularity (Chapter 18); overflow_run
% is the longer run that makes a deep stack a suspected
% Stack Overflow (User Mode) (Chapter 19).
threshold(spiking_share, 25).
threshold(frame_run, 4).
threshold(overflow_run, 6).
threshold(null_page, 0x1_0000).
threshold(stack_depth, 12).
threshold(committed_ratio, 0.85).
threshold(large_heap_kb, 1048576).
threshold(committed_total_kb, 1572864).
threshold(handle_type_count, 5000).
threshold(handle_total_count, 10000).
threshold(leak_growth_kb, 65536).

% system_module(Module): a module supplied by the
% operating system or the C runtime. The analyst's
% knowledge, as in Chapter 22.
system_module(ntdll).
system_module(kernelbase).
system_module(kernel32).
system_module(ucrtbase).
system_module(msvcp140).


% ---- Chapter 18: stack traces and threads ----

% stack_trace(TID, Frames): Frames is the list of
% frame/5 terms of thread TID, top frame first.
stack_trace(TID, Frames) :-
    findall(frame(TID, N, M, F, O),
            user:frame(TID, N, M, F, O), Frames0),
    sort(2, @=<, Frames0, Frames).

% entry_function(F): F is an entry function that
% the main thread's stack trace passes through.
entry_function(main).
entry_function(wmain).
entry_function('WinMain').
entry_function('wWinMain').

% main_thread(TID): TID is the main thread.
main_thread(TID) :-
    user:thread(TID, _),
    once(( user:frame(TID, _, _, F, _),
           entry_function(F)
         )).

% cpu_time(TID, Ms): the CPU time of TID in ms.
cpu_time(TID, Ms) :-
    user:thread_time(TID, User, Kernel),
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

% blocked_thread(TID): the dump records an object
% TID waits for.
blocked_thread(TID) :-
    user:waits_for(TID, _, _).

% wait_function(F): F is a frame of the critical
% section wait path in ntdll.
wait_function('RtlpWaitOnCriticalSection').
wait_function('RtlEnterCriticalSection').

% blocked_thread(TID, Evidence): as
% blocked_thread/1, with the object and the wait
% frames as evidence.
blocked_thread(TID, Evidence) :-
    user:waits_for(TID, Kind, Addr),
    findall(frame(TID, N, M, F, O),
            ( user:frame(TID, N, M, F, O),
              wait_function(F)
            ),
            Frames),
    Facts = [waits_for(TID, Kind, Addr) | Frames],
    Name = 'Blocked Thread (Software)',
    Evidence = evidence(Name, TID, Facts).

% frame_key(Frame, Key): Key is the pair
% Module-Function of the frame/5 term Frame.
frame_key(frame(_, _, M, F, _), M-F).

% stack_trace_signature(TID, Signature): the keys
% of the frames of TID, top frame first.
stack_trace_signature(TID, Signature) :-
    stack_trace(TID, Frames),
    maplist(frame_key, Frames, Signature).

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
    user:thread(TID, _),
    stack_trace_signature(TID, Signature),
    runs(Signature, Runs),
    member(Key-Count, Runs),
    threshold(frame_run, Min),
    Count >= Min.


% ---- Chapters 1 and 23: thread state ----

% suspended_thread(TID): TID is suspended.
suspended_thread(TID) :-
    user:thread_state(TID, suspended).


% ---- Chapter 19: exceptions and faults ----

% exception_stack_trace(TID, Frames): TID has an
% exception record and Frames is its stack trace.
exception_stack_trace(TID, Frames) :-
    user:exception_record(TID, _, _),
    stack_trace(TID, Frames).

% access_violation(TID): the exception of TID is
% an access violation.
access_violation(TID) :-
    user:exception_record(TID, 0xc0000005, _).

% null_pointer_data(TID): TID read or wrote
% through a null pointer.
null_pointer_data(TID) :-
    access_violation(TID),
    user:exception_info(TID, access, Access),
    Access \== execute,
    user:exception_info(TID, target, Target),
    threshold(null_page, Limit),
    Target < Limit.

% null_pointer_data(TID, Evidence): as above, with
% the facts the recognition rests on: the record,
% its parameters, and the null page limit.
null_pointer_data(TID, Evidence) :-
    null_pointer_data(TID),
    user:exception_record(TID, Code, Addr),
    findall(exception_info(TID, K, V),
            user:exception_info(TID, K, V), Info),
    threshold(null_page, Limit),
    Facts = [exception_record(TID, Code, Addr)
             | Rest],
    append(Info, [threshold(null_page, Limit)],
           Rest),
    Evidence = evidence('NULL Pointer (Data)',
                        TID, Facts).

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
    user:exception_record(TID, 0xc00000fd, Addr),
    Name = 'Stack Overflow (User Mode)',
    Code = 0xc00000fd,
    Facts = [exception_record(TID, Code, Addr)],
    Finding = evidence(Name, TID, Facts).
stack_overflow(TID, Finding) :-
    user:thread(TID, PID),
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


% ---- Chapter 20: synchronization ----

% wait_fact(TID, Kind, Object, Fact): Fact is the
% fact, of the shared file or of the extension,
% that records that TID waits for Object of Kind.
wait_fact(T, K, O, waits_for(T, K, O)) :-
    user:waits_for(T, K, O).
wait_fact(T, K, O, waits_for_object(T, K, O)) :-
    user:waits_for_object(T, K, O).

% waits(TID, Kind, Object): TID waits for Object
% of Kind, by the shared facts or the extension.
waits(TID, Kind, Object) :-
    wait_fact(TID, Kind, Object, _).

% wait_edge(Kind, Waiter, Owner, Facts): Waiter
% waits for an object of Kind that Owner holds;
% Facts are the wait fact and the ownership fact
% that say so.
wait_edge(critical_section, W, O,
          [Wait, critical_section(A, O, L, R)]) :-
    wait_fact(W, critical_section, A, Wait),
    user:critical_section(A, O, L, R),
    O =\= 0.
wait_edge(mutant, W, O,
          [Wait, mutant(H, O, N)]) :-
    wait_fact(W, mutant, H, Wait),
    user:mutant(H, O, N),
    O =\= 0.
wait_edge(thread, W, O, [Wait]) :-
    wait_fact(W, thread, O, Wait).

% wait_edge(Kind, Waiter, Owner): the edge without
% its facts.
wait_edge(Kind, W, O) :-
    wait_edge(Kind, W, O, _).

% edge_of(+Kind, ?W, ?O, -Edge): a wait edge of
% Kind, or of any kind when Kind is the atom any;
% Edge is K-Facts, the kind of the edge and the
% facts that make it.
edge_of(Kind, W, O, K-Facts) :-
    must_be(oneof([critical_section, mutant,
                   thread, any]), Kind),
    (   Kind == any
    ->  wait_edge(K, W, O, Facts)
    ;   K = Kind,
        wait_edge(K, W, O, Facts)
    ).

% edge_of(+Kind, ?W, ?O): the edge without its
% kind and facts.
edge_of(Kind, W, O) :-
    edge_of(Kind, W, O, _).

% wait_chain(+Kind, -Chain): Chain is the path of
% Kind edges from a waiting thread, followed until
% the next thread would repeat one in the chain.
wait_chain(Kind, [T | Rest]) :-
    edge_of(Kind, T, _),
    follow(Kind, T, [T], Rest).

follow(Kind, T, Visited, Chain) :-
    (   edge_of(Kind, T, Next),
        \+ memberchk(Next, Visited)
    ->  Chain = [Next | Rest],
        follow(Kind, Next, [Next | Visited], Rest)
    ;   Chain = []
    ).

% deadlock_witness(+Kind, -Cycle, -Edges): Cycle
% is a list of threads each waiting, through an
% object of Kind, for the next, and the last for
% the first, the first the smallest; Edges holds,
% in the same order, the edge each thread was
% followed along: its kind and the facts that make
% it, as edge_of/4 selected them.
deadlock_witness(Kind, [T | Path],
                 [Edge | Edges]) :-
    edge_of(Kind, T, Next, Edge),
    cycle_from(Kind, T, Next, [T], Path, Edges),
    min_list([T | Path], T).

% cycle_from(Kind, Start, Current, Visited, Path,
% Edges): Path leads from Current back to Start
% along Kind edges without repeating a thread, and
% Edges are the edges followed.
cycle_from(Kind, Start, Current, Visited,
           Path, Edges) :-
    (   Current == Start
    ->  Path = [],
        Edges = []
    ;   \+ memberchk(Current, Visited),
        Path = [Current | Rest],
        Edges = [Edge | Rest1],
        edge_of(Kind, Current, Next, Edge),
        cycle_from(Kind, Start, Next,
                   [Current | Visited],
                   Rest, Rest1)
    ).

% deadlock(+Kind, -Cycle): Cycle is a cycle of
% Kind edges, from its smallest thread; the
% witness is dropped.
deadlock(Kind, Cycle) :-
    deadlock_witness(Kind, Cycle, _).

% cycle_kinds(Edges, Kinds): Kinds is the set of
% kinds of the edges Edges of a witness.
cycle_kinds(Edges, Kinds) :-
    pairs_keys(Edges, Kinds0),
    sort(Kinds0, Kinds).

% deadlock_name(Kinds, Name): the catalog name of
% a deadlock whose selected edges have the set of
% kinds Kinds: the critical section variant, the
% mixed variant for two kinds or more, and the
% family name for one kind of another object.
deadlock_name([critical_section],
              'Deadlock (Critical Sections)').
deadlock_name([Kind], 'Deadlock') :-
    Kind \== critical_section.
deadlock_name([_, _ | _],
              'Deadlock (Mixed Objects)').

% deadlock(+Kind, -Cycle, -Evidence): as the test
% above; the evidence holds the facts of the edges
% the walk selected, the wait fact and the
% ownership fact of each, and the pattern is named
% from the kinds of those edges. Under a variant
% name the instance is the cycle; under the family
% name it is cycle(Kind, Cycle), so that the kind
% of object is reported.
deadlock(Kind, Cycle, Evidence) :-
    deadlock_witness(Kind, Cycle, Edges),
    cycle_kinds(Edges, Kinds),
    deadlock_name(Kinds, Name),
    (   Kinds = [One],
        One \== critical_section
    ->  Instance = cycle(One, Cycle)
    ;   Instance = Cycle
    ),
    pairs_values(Edges, Lists),
    append(Lists, Facts),
    Evidence = evidence(Name, Instance, Facts).


% ---- Chapter 21: memory, handles, and leaks ----

% committed_ratio(Heap, Ratio): Ratio is the
% committed part of Heap over its reservation.
committed_ratio(Heap, Ratio) :-
    user:heap(Heap, Reserved, Committed, _),
    Reserved > 0,
    Ratio is Committed / Reserved.

% insufficient_memory(Variant, Instance): the two
% variants of the pattern treated in Chapter 21.
insufficient_memory(committed_memory, heap(H)) :-
    committed_ratio(H, Ratio),
    threshold(committed_ratio, MinRatio),
    Ratio >= MinRatio,
    user:heap(H, Reserved, _, _),
    threshold(large_heap_kb, MinKb),
    Reserved >= MinKb.
insufficient_memory(committed_memory, process) :-
    aggregate_all(sum(C), user:heap(_, _, C, _),
                  Total),
    threshold(committed_total_kb, MaxKb),
    Total >= MaxKb.
insufficient_memory(handle_leak, process(PID)) :-
    user:process(PID, _),
    aggregate_all(sum(C),
                  user:handle_count(PID, _, C),
                  Total),
    threshold(handle_total_count, Max),
    Total > Max.

% variant_name(Variant, Name): the catalog name of
% a variant of Insufficient Memory.
variant_name(committed_memory,
    'Insufficient Memory (Committed Memory)').
variant_name(handle_leak,
    'Insufficient Memory (Handle Leak)').

% insufficient_memory(Variant, Instance, Ev): the
% explainer form for heap instances: the heap and
% the two thresholds the first clause compared it
% with.
insufficient_memory(committed_memory, I, E) :-
    I = heap(H),
    insufficient_memory(committed_memory, I),
    user:heap(H, R, C, F),
    threshold(committed_ratio, Min),
    threshold(large_heap_kb, MinKb),
    variant_name(committed_memory, Name),
    Facts = [ heap(H, R, C, F),
              threshold(committed_ratio, Min),
              threshold(large_heap_kb, MinKb)
            ],
    E = evidence(Name, I, Facts).

% handle_leak(Type): the count of handles of Type
% exceeds the analyst's limit for one type.
handle_leak(Type) :-
    user:handle_count(_, Type, Count),
    threshold(handle_type_count, Max),
    Count > Max.

% committed_series(Heap, Series): Series is the
% list of Time-CommittedKb pairs of Heap in time
% order, over the heap_at/5 and dump_time/2
% extension of Chapter 21.
committed_series(Heap, Series) :-
    findall(T-C,
            ( user:heap_at(D, Heap, _, C, _),
              user:dump_time(D, T)
            ),
            Pairs),
    keysort(Pairs, Series).

% strictly_increasing(Series): every value is
% greater than the one before it.
strictly_increasing([_-C0 | Pairs]) :-
    increasing_from(Pairs, C0).

% increasing_from(Pairs, Prev): the values of
% Pairs increase, starting above Prev.
increasing_from([], _).
increasing_from([_-C | Pairs], Prev) :-
    Prev < C,
    increasing_from(Pairs, C).

% memory_leak(Heap): the committed size of Heap
% grows at every snapshot, by at least the leak
% threshold over the series.
memory_leak(Heap) :-
    user:heap(Heap, _, _, _),
    committed_series(Heap, Series),
    Series = [_-First, _ | _],
    strictly_increasing(Series),
    last(Series, _-Last),
    threshold(leak_growth_kb, MinGrowth),
    Last - First >= MinGrowth.


% ---- Chapter 22: modules and environment ----

% vendor(Module, Vendor): the company recorded for
% Module; system for a system module without one;
% unrecorded otherwise.
vendor(Module, Vendor) :-
    user:module(Module, _, _),
    (   user:module_info(Module, company, Company)
    ->  Vendor = Company
    ;   system_module(Module)
    ->  Vendor = system
    ;   Vendor = unrecorded
    ).

% version_parts(Version, Parts): the numbers of a
% dotted version atom, as a list.
version_parts(Version, Parts) :-
    atomic_list_concat(Texts, '.', Version),
    maplist(atom_number, Texts, Parts).

% main_module(Module): the module of the process's
% executable, by its file name.
main_module(Module) :-
    user:process(_, Executable),
    file_name_extension(Base, _, Executable),
    downcase_atom(Base, Module),
    user:module(Module, _, _).

% version_of(Module, Parts): the version of Module
% as a list of numbers; a module has one version.
version_of(Module, Parts) :-
    once(user:module_info(Module, version, Version)),
    version_parts(Version, Parts).

% not_my_version(Module): Module is from the same
% vendor as the executable but has a different
% version.
not_my_version(Module) :-
    main_module(Main),
    vendor(Main, Vendor),
    vendor(Module, Vendor),
    Module \== Main,
    version_of(Main, MainParts),
    version_of(Module, Parts),
    MainParts \== Parts.

% unknown_component(Module): the dump records no
% vendor for Module, or records it as unknown.
unknown_component(Module) :-
    vendor(Module, Vendor),
    memberchk(Vendor, ['Unknown', unrecorded]).

% no_component_symbols(Module): the debugger had
% no symbol file for Module.
no_component_symbols(Module) :-
    user:module_info(Module, symbols, Kind),
    Kind \== pdb.

% hooked_functions(Module, Hooker, Functions): the
% functions of Module that Hooker hooks.
hooked_functions(Module, Hooker, Functions) :-
    bagof(Function,
          user:hooked(Function, Module, Hooker),
          Functions).

% last_error_collection(Collection): the TID-Code
% pairs of every thread with a recorded last
% error, by thread.
last_error_collection(Collection) :-
    findall(TID-Code, user:last_error(TID, Code),
            Pairs),
    keysort(Pairs, Collection).


% ---- Chapters 17 and 23: the evidence contract ----

% explainer(Goal, Finding): Goal is an explainer of
% this module, with its instance unbound, and
% Finding is the evidence or suspicion term that a
% call of Goal binds.
explainer(spiking_thread(_, Finding), Finding).
explainer(blocked_thread(_, Finding), Finding).
explainer(null_pointer_data(_, Finding), Finding).
explainer(stack_overflow(_, Finding), Finding).
explainer(deadlock(any, _, Finding), Finding).
explainer(insufficient_memory(committed_memory, _,
                              Finding), Finding).

% finding_facts(Finding, Facts): Facts are the
% leaves of an evidence or suspicion term.
finding_facts(evidence(_, _, Facts), Facts).
finding_facts(suspected(_, _, Facts), Facts).

% dump_relation(Name/Arity): the relations of the
% dump schema of Section 15.2 and the extension
% relations of Chapters 20 and 21. A goal of one of
% them follows from the evidence list alone,
% however it is qualified.
dump_relation(process/2).
dump_relation(module/3).
dump_relation(module_info/3).
dump_relation(thread/2).
dump_relation(thread_time/3).
dump_relation(thread_state/2).
dump_relation(frame/5).
dump_relation(exception_record/3).
dump_relation(exception_info/3).
dump_relation(critical_section/4).
dump_relation(waits_for/3).
dump_relation(handle_count/3).
dump_relation(heap/4).
dump_relation(last_error/2).
dump_relation(hooked/3).
dump_relation(mutant/3).
dump_relation(waits_for_object/3).
dump_relation(heap_at/5).
dump_relation(dump_time/2).

% derivable(+Facts, +Goal): Goal follows from the
% list Facts alone. The control constructs and the
% all-solutions and apply predicates the recognizers
% use are interpreted, so that every goal they call
% is derived in turn; a relation of the dump and a
% threshold follow only as members of Facts, whatever
% module qualifies them, and so does any other fact
% of user, the module of the knowledge base; a goal
% of a predicate defined by clauses, in this module
% or in a chapter, follows as a member of Facts or
% through a clause whose body follows; a first-order
% built-in from the list of evaluable/1 is called;
% must_be/2 is decided by checked/2 for a fixed list
% of descriptors, since the library predicate
% dispatches through an extensible hook; and any
% other goal is outside the vocabulary and raises a
% domain error, rather than being called. A goal or
% list with an attributed variable (Chapter 14) is
% refused, since unifying one runs a hook.
derivable(Facts, Goal) :-
    term_attvars(Facts-Goal, Vars),
    (   Vars == []
    ->  derive(Goal, patterns_dump, Facts)
    ;   Vars = [Var | _],
        copy_term(Var, Plain, _),
        permission_error(derive, attributed_variable,
                         Plain)
    ).

derive(G, _, _) :-
    var(G),
    !,
    instantiation_error(G).
derive(M:G, _, Facts) :-
    !,
    derive(G, M, Facts).
derive(true, _, _) :- !.
derive((A, B), M, Facts) :-
    !,
    derive(A, M, Facts),
    derive(B, M, Facts).
derive((If -> Then ; Else), M, Facts) :-
    !,
    (   derive(If, M, Facts)
    ->  derive(Then, M, Facts)
    ;   derive(Else, M, Facts)
    ).
derive((If *-> Then ; Else), M, Facts) :-
    !,
    (   derive(If, M, Facts)
    *-> derive(Then, M, Facts)
    ;   derive(Else, M, Facts)
    ).
derive((A ; B), M, Facts) :-
    !,
    (   derive(A, M, Facts)
    ;   derive(B, M, Facts)
    ).
derive((If -> Then), M, Facts) :-
    !,
    (   derive(If, M, Facts)
    ->  derive(Then, M, Facts)
    ).
derive(\+ A, M, Facts) :-
    !,
    \+ derive(A, M, Facts).
derive(not(A), M, Facts) :-
    !,
    \+ derive(A, M, Facts).
derive(once(A), M, Facts) :-
    !,
    once(derive(A, M, Facts)).
derive(ignore(A), M, Facts) :-
    !,
    ignore(derive(A, M, Facts)).
derive(forall(C, A), M, Facts) :-
    !,
    forall(derive(C, M, Facts),
           derive(A, M, Facts)).
derive(catch(G, E, R), M, Facts) :-
    !,
    catch(derive(G, M, Facts), E,
          derive(R, M, Facts)).
derive(findall(T, G, L), M, Facts) :-
    !,
    findall(T, derive(G, M, Facts), L).
derive(findall(T, G, L, Tail), M, Facts) :-
    !,
    findall(T, derive(G, M, Facts), L, Tail).
derive(bagof(T, G, L), M, Facts) :-
    !,
    existential(G, Vs, G1),
    bagof(T, Vs^derive(G1, M, Facts), L).
derive(setof(T, G, L), M, Facts) :-
    !,
    existential(G, Vs, G1),
    setof(T, Vs^derive(G1, M, Facts), L).
derive(aggregate_all(S, G, R), M, Facts) :-
    !,
    aggregate_all(S, derive(G, M, Facts), R).
derive(aggregate_all(S, D, G, R), M, Facts) :-
    !,
    aggregate_all(S, D, derive(G, M, Facts), R).
derive(G, M, Facts) :-
    applied(G, Closure, Args),
    !,
    add_args(Closure, Args, G1),
    derive(G1, M, Facts).
derive(maplist(P, L), M, Facts) :-
    !,
    maplist(derive_with(M, Facts, P), L).
derive(maplist(P, L1, L2), M, Facts) :-
    !,
    maplist(derive_with(M, Facts, P), L1, L2).
derive(maplist(P, L1, L2, L3), M, Facts) :-
    !,
    maplist(derive_with(M, Facts, P), L1, L2, L3).
derive(include(P, L, R), M, Facts) :-
    !,
    include(derive_with(M, Facts, P), L, R).
derive(exclude(P, L, R), M, Facts) :-
    !,
    exclude(derive_with(M, Facts, P), L, R).
derive(foldl(P, L, V0, V), M, Facts) :-
    !,
    foldl(derive_with(M, Facts, P), L, V0, V).
derive(G, _, Facts) :-
    functor(G, Name, Arity),
    (   dump_relation(Name/Arity)
    ;   Name/Arity == threshold/2
    ),
    !,
    fact_of(G, Facts).
derive(must_be(Type, X), _, _) :-
    !,
    checked(Type, X).
derive(G, _, _) :-
    functor(G, Name, Arity),
    evaluable(Name/Arity, Module),
    !,
    call(Module:G).
derive(G, M, Facts) :-
    program_predicate(M:G, Defined),
    !,
    (   fact_of(G, Facts)
    ;   clause(Defined:G, Body),
        \+ ( Defined == user, Body == true ),
        derive(Body, Defined, Facts)
    ).
derive(G, _, _) :-
    functor(G, Name, Arity),
    domain_error(derivable_goal, Name/Arity).

% fact_of(+Goal, +Facts): Goal is a member of Facts,
% the members' module qualifications ignored.
fact_of(G, Facts) :-
    member(F0, Facts),
    strip_module(F0, _, G).

% existential(+Goal, -Vars, -Plain): Goal without
% its V^ prefixes, which list the variables Vars.
existential(V^G, [V | Vs], G1) :-
    !,
    existential(G, Vs, G1).
existential(G, [], G).

% applied(+Goal, -Closure, -Args): Goal is call/N.
applied(G, Closure, Args) :-
    G =.. [call, Closure | Args].

% add_args(+Closure, +Args, -Goal): Goal is Closure
% with Args appended to its arguments.
add_args(M:C, Args, M:G) :-
    !,
    add_args(C, Args, G).
add_args(C, Args, G) :-
    C =.. L0,
    append(L0, Args, L1),
    G =.. L1.

% derive_with(+M, +Facts, +Closure, ...): the closure
% applied to the extra arguments is derived.
derive_with(M, Facts, P, A) :-
    add_args(P, [A], G),
    derive(G, M, Facts).
derive_with(M, Facts, P, A, B) :-
    add_args(P, [A, B], G),
    derive(G, M, Facts).
derive_with(M, Facts, P, A, B, C) :-
    add_args(P, [A, B, C], G),
    derive(G, M, Facts).

% checked(+Type, @Term): must_be(Type, Term) decided
% for the descriptors of derivable_type/1 with the
% tests and the error terms of library(error) of
% SWI-Prolog 9.0.4, reproduced here, so that the
% hook has_type/2 of that library, which a loaded
% file may extend with clauses of its own, is never
% consulted. The whole descriptor is validated
% first, element types included; one outside the
% vocabulary raises a domain error, whatever the
% term, which is the one way this differs from the
% library predicate.
checked(Type, X) :-
    descriptor(Type),
    (   of_type(Type, X)
    ->  true
    ;   not_of_type(Type, X)
    ).

% descriptor(+Type): Type is in the vocabulary of
% derivable_type/1, its element type included.
descriptor(Type) :-
    var(Type),
    !,
    instantiation_error(Type).
descriptor(list(Type)) :-
    !,
    descriptor(Type).
descriptor(Type) :-
    derivable_type(Type),
    !.
descriptor(Type) :-
    domain_error(derivable_type, Type).

% derivable_type(@Type): a descriptor checked/2
% decides.
derivable_type(oneof(_)).
derivable_type(atom).
derivable_type(atomic).
derivable_type(integer).
derivable_type(nonneg).
derivable_type(positive_integer).
derivable_type(number).
derivable_type(boolean).
derivable_type(callable).
derivable_type(list).
derivable_type(list(_)).
derivable_type(between(_, _)).

% of_type(+Type, @X): has_type/2 of library(error)
% for the vocabulary, clause for clause.
of_type(atom, X) :- atom(X).
of_type(atomic, X) :- atomic(X).
of_type(between(L, U), X) :-
    (   integer(L)
    ->  integer(X), between(L, U, X)
    ;   number(X), X >= L, X =< U
    ).
of_type(boolean, X) :- ( X == true ; X == false ), !.
of_type(callable, X) :- callable(X).
of_type(integer, X) :- integer(X).
of_type(nonneg, X) :- integer(X), X >= 0.
of_type(positive_integer, X) :- integer(X), X > 0.
of_type(number, X) :- number(X).
of_type(oneof(L), X) :- ground(X), \+ \+ memberchk(X, L).
of_type(list, X) :- is_list(X).
of_type(list(Type), X) :-
    is_list(X),
    elements_of_type(X, Type).

elements_of_type([], _).
elements_of_type([H | T], Type) :-
    of_type(Type, H),
    !,
    elements_of_type(T, Type).

% not_of_type(+Type, @X): is_not/2 of library(error)
% for the vocabulary: X is known not to be of Type,
% and the error says how.
not_of_type(list, X) :-
    !,
    not_a_list(list, X).
not_of_type(list(Of), X) :-
    !,
    not_a_list(list(Of), X).
not_of_type(Type, X) :-
    (   var(X)
    ->  instantiation_error(X)
    ;   Type = oneof(_),
        \+ ground(X)
    ->  instantiation_error(X)
    ;   type_error(Type, X)
    ).

not_a_list(Type, X) :-
    '$skip_list'(_, X, Rest),
    (   var(Rest)
    ->  instantiation_error(X)
    ;   Rest == []
    ->  Type = list(Of),
        element_not_of_type(X, Of)
    ;   type_error(Type, X)
    ).

element_not_of_type([H | T], Of) :-
    of_type(Of, H),
    !,
    element_not_of_type(T, Of).
element_not_of_type([H | _], Of) :-
    not_of_type(Of, H).

% program_predicate(+M:Goal, -Defined): the
% predicate of Goal, resolved in module M, has
% clauses, and Defined is the module that defines
% them.
program_predicate(M:G, Defined) :-
    predicate_property(M:G, defined),
    \+ predicate_property(M:G, built_in),
    \+ predicate_property(M:G, foreign),
    (   predicate_property(M:G, imported_from(D))
    ->  Defined = D
    ;   Defined = M
    ),
    \+ ( module_property(Defined, class(Class)),
         Class \== user
       ).

% evaluable(?Name/Arity): the first-order built-ins
% and library predicates that a derivation calls
% rather than derives: unification and comparison,
% arithmetic, type tests, term construction, atoms
% and strings, and lists. None reads the database,
% calls a goal of its own, or dispatches through a
% hook that a loaded file could extend.
evaluable(PI) :-
    evaluable(PI, _).

% evaluable(?Name/Arity, ?Module): as evaluable/1,
% with the module that defines the predicate; the
% derivation calls it there, so that a definition
% of the same name in user, which a meta-call from
% this module would otherwise reach first, is not
% used in its place.
evaluable((=)/2, system).
evaluable((\=)/2, system).
evaluable((==)/2, system).
evaluable((\==)/2, system).
evaluable((@<)/2, system).
evaluable((@>)/2, system).
evaluable((@=<)/2, system).
evaluable((@>=)/2, system).
evaluable(compare/3, system).
evaluable((is)/2, system).
evaluable((<)/2, system).
evaluable((>)/2, system).
evaluable((=<)/2, system).
evaluable((>=)/2, system).
evaluable((=:=)/2, system).
evaluable((=\=)/2, system).
evaluable(succ/2, system).
evaluable(plus/3, system).
evaluable(between/3, system).
evaluable(var/1, system).
evaluable(nonvar/1, system).
evaluable(atom/1, system).
evaluable(number/1, system).
evaluable(integer/1, system).
evaluable(float/1, system).
evaluable(atomic/1, system).
evaluable(compound/1, system).
evaluable(callable/1, system).
evaluable(is_list/1, system).
evaluable(ground/1, system).
evaluable(functor/3, system).
evaluable(arg/3, system).
evaluable((=..)/2, system).
evaluable(copy_term/2, system).
evaluable(atom_number/2, system).
evaluable(atom_length/2, system).
evaluable(atom_concat/3, system).
evaluable(atomic_list_concat/2, system).
evaluable(atomic_list_concat/3, system).
evaluable(sub_atom/5, system).
evaluable(downcase_atom/2, system).
evaluable(upcase_atom/2, system).
evaluable(file_name_extension/3, system).
evaluable(atom_codes/2, system).
evaluable(atom_chars/2, system).
evaluable(atom_string/2, system).
evaluable(number_codes/2, system).
evaluable(string_concat/3, system).
evaluable(split_string/4, system).
evaluable(length/2, system).
evaluable(member/2, lists).
evaluable(memberchk/2, system).
evaluable(append/2, lists).
evaluable(append/3, lists).
evaluable(reverse/2, lists).
evaluable(nth0/3, lists).
evaluable(nth1/3, lists).
evaluable(last/2, lists).
evaluable(msort/2, system).
evaluable(sort/2, system).
evaluable(sort/4, system).
evaluable(keysort/2, system).
evaluable(pairs_keys_values/3, pairs).
evaluable(pairs_keys/2, pairs).
evaluable(pairs_values/2, pairs).
evaluable(list_to_set/2, lists).
evaluable(sum_list/2, lists).
evaluable(max_list/2, lists).
evaluable(min_list/2, lists).
evaluable(max_member/2, lists).
evaluable(min_member/2, lists).
evaluable(numlist/3, lists).
evaluable(subtract/3, lists).
evaluable(intersection/3, lists).
evaluable(union/3, lists).
evaluable(delete/3, lists).
evaluable(select/3, lists).
evaluable(selectchk/3, lists).

% sufficient(+Finding): the evidence or suspicion
% term Finding re-derives from its own leaves: the
% explainer that produces findings of its shape,
% called with Finding bound, follows from the
% leaves alone by derivable/2.
sufficient(Finding) :-
    finding_facts(Finding, Facts),
    once(( explainer(Goal, Finding),
           derivable(Facts, Goal)
        )).

% check_finding(+Ctx, +Finding, -Verdict): Verdict
% is ok when Finding keeps the contract of Section
% 17.3 with its leaves called in module Ctx, and
% otherwise names the part it breaks: not_ground;
% fails(Leaf) or raises(Leaf, Error) for a leaf
% that does not succeed in Ctx; or insufficient.
check_finding(Ctx, Finding, Verdict) :-
    finding_facts(Finding, Facts),
    (   \+ ground(Facts)
    ->  Verdict = not_ground
    ;   member(Leaf, Facts),
        leaf_verdict(Ctx, Leaf, Verdict0),
        Verdict0 \== ok
    ->  Verdict = Verdict0
    ;   sufficient(Finding)
    ->  Verdict = ok
    ;   Verdict = insufficient
    ).

% leaf_verdict(+Ctx, +Leaf, -Verdict): Leaf called
% in Ctx succeeds, fails, or raises Error.
leaf_verdict(Ctx, Leaf, Verdict) :-
    catch(( Ctx:Leaf
          ->  Verdict = ok
          ;   Verdict = fails(Leaf)
          ),
          error(Error, _),
          Verdict = raises(Leaf, Error)).

:- module_transparent check_explainers/0.

% check_explainers: every finding of every
% explainer of explainer/2, on the knowledge base
% loaded, keeps the contract, with its leaves
% called in the module that calls this predicate;
% one line per explainer, and one per finding that
% breaks the contract, in which case the check
% fails.
check_explainers :-
    context_module(Ctx),
    patterns_dump:check_explainers_in(Ctx).

% check_explainers_in(+Ctx): as check_explainers/0,
% with the leaves called in Ctx.
check_explainers_in(Ctx) :-
    findall(Goal-Verdict,
            ( explainer(Goal, Finding),
              call(Goal),
              check_finding(Ctx, Finding, Verdict)
            ),
            Results),
    forall(explainer(Goal, _),
           report_explainer(Goal, Results)),
    forall(member(_-Verdict, Results),
           Verdict == ok).

% report_explainer(+Goal, +Results): one line for
% the explainer Goal with the number of its
% findings that keep the contract, and one line for
% each finding that does not.
report_explainer(Goal, Results) :-
    functor(Goal, Name, Arity),
    findall(Instance-Verdict,
            ( member(Goal-Verdict, Results),
              arg(Arity, Goal, Finding),
              arg(2, Finding, Instance)
            ),
            Own),
    aggregate_all(count, member(_-ok, Own), Ok),
    length(Own, N),
    format("~a/~d: ~d of ~d ok~n",
           [Name, Arity, Ok, N]),
    forall(( member(Instance-Verdict, Own),
             Verdict \== ok
           ),
           format("    ~q: ~q~n", [Instance, Verdict])).
```

```{.prolog .query}
?- use_module(patterns_dump).
true.

?- deadlock(critical_section, C).
C = [103, 104] ;
false.
```

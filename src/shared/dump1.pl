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

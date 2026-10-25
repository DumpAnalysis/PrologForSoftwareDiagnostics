% faults.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 19. Exceptions and Faults.
% Program block 1 of the chapter.

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

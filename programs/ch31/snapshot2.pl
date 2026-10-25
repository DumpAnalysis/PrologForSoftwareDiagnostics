% snapshot2.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 31. Integration: Scripts, Embedding, and Debugger Extensions: 31.7.2 The Schema of Part II over a Snapshot.
% Program block 7 of the chapter.

% two_thread_snapshot(Facts): two threads with one
% captured frame each, for the regression case.
two_thread_snapshot(
    [ target(2, dump, 4120, 8),
      architecture(2, amd64),
      coverage(2, threads, enumerated(2)),
      thread(2, 2), thread_id(2, 2, 102),
      thread(2, 3), thread_id(2, 3, 105),
      coverage(2, stack(2),
          captured_prefix(1, frame_limit)),
      coverage(2, stack(3),
          captured_prefix(1, frame_limit)),
      stack_frame(2, 2, 0, 0x7ffb_8e41_1a3e),
      stack_frame(2, 3, 0, 0x7ff6_1d11_3b10),
      symbol(2, 0x7ffb_8e41_1a3e, 'ReportEngine',
             'Table::Find', 0x3e),
      symbol(2, 0x7ff6_1d11_3b10, 'AppServer',
             'Idle::Wait', 0x10),
      coverage(2, modules, enumerated(0))
    ]).

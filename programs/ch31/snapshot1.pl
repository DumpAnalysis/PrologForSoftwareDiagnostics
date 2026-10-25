% snapshot1.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 31. Integration: Scripts, Embedding, and Debugger Extensions: 31.7.2 The Schema of Part II over a Snapshot.
% Program block 5 of the chapter.

% sample_snapshot(Facts): a snapshot shaped as the
% extension sends it, for thread 102 of dump1.pl
% as the engine would capture it: engine thread
% 2, the seven frames, the symbols of their
% addresses, and the coverage statuses.
sample_snapshot(
    [ target(1, dump, 4120, 8),
      architecture(1, amd64),
      coverage(1, threads, enumerated(1)),
      thread(1, 2),
      thread_id(1, 2, 102),
      coverage(1, stack(2),
          captured_prefix(7, unverified_end)),
      stack_frame(1, 2, 0, 0x7ffb_8e41_1a3e),
      stack_frame(1, 2, 1, 0x7ffb_8e41_209a),
      stack_frame(1, 2, 2, 0x7ffb_8e45_0214),
      stack_frame(1, 2, 3, 0x7ff6_1d11_2120),
      stack_frame(1, 2, 4, 0x7ffb_ae51_8042),
      stack_frame(1, 2, 5, 0x7ffb_b1c1_7614),
      stack_frame(1, 2, 6, 0x7ffb_b2a5_2a21),
      symbol(1, 0x7ffb_8e41_1a3e, 'ReportEngine',
             'Table::Find', 0x3e),
      symbol(1, 0x7ffb_8e41_209a, 'ReportEngine',
             'Table::Insert', 0x9a),
      symbol(1, 0x7ffb_8e45_0214, 'ReportEngine',
             'Report::Build', 0x214),
      symbol(1, 0x7ff6_1d11_2120, 'AppServer',
             'Worker::Run', 0x120),
      symbol(1, 0x7ffb_ae51_8042, ucrtbase,
             'thread_start<...>', 0x42),
      symbol(1, 0x7ffb_b1c1_7614, kernel32,
             'BaseThreadInitThunk', 0x14),
      symbol(1, 0x7ffb_b2a5_2a21, ntdll,
             'RtlUserThreadStart', 0x21),
      coverage(1, modules, enumerated(3)),
      module(1, 'AppServer', 0x7ff6_1d10_0000,
             0x3c000),
      module(1, 'ReportEngine', 0x7ffb_8e40_0000,
             0x1a2000),
      module(1, ntdll, 0x7ffb_b2a0_0000, 0x1f8000)
    ]).

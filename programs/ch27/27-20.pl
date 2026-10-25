% 27-20.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.19 Exception Stack Trace.
% Program block 20 of the chapter.

:- multifile msg/6.

msg(72, 14.011, 4120, 109, appserver,
    "Stack trace for thread 109:").
msg(73, 14.011, 4120, 109, appserver,
    "  00 dbclient!Buffer::Copy+0x1a").
msg(74, 14.012, 4120, 109, appserver,
    "  01 dbclient!Connection::Receive+0x8c").
msg(75, 14.012, 4120, 109, appserver,
    "  02 appserver!Session::Fetch+0x44").
msg(76, 14.013, 4120, 109, appserver,
    "  03 appserver!Worker::Run+0x120").
msg(77, 14.013, 4120, 109, appserver,
    "  04 ucrtbase!thread_start<...>+0x42").
msg(78, 14.014, 4120, 109, appserver,
    "  05 kernel32!BaseThreadInitThunk+0x14").
msg(79, 14.014, 4120, 109, appserver,
    "  06 ntdll!RtlUserThreadStart+0x21").

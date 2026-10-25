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

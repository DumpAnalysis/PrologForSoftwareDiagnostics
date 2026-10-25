% 21-14.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 21. Memory, Heaps, Handles, and Leaks: 21.13 Data Correlation (Function Parameters).
% Program block 14 of the chapter.

% frame_param(TID, N, I, Value): the I-th
% parameter of frame N of thread TID as the
% debugger reconstructs it. An extension of the
% schema.
frame_param(109, 0, 1, 0x0).
frame_param(109, 0, 2, 0x0000_0210_a204_1040).
frame_param(109, 0, 3, 0x400).
frame_param(109, 1, 1, 0x0000_0210_a003_2a00).
frame_param(109, 1, 2, 0x0000_0210_a204_1040).
frame_param(109, 2, 1, 0x0000_0210_a003_2a00).

% data_correlation(TID, Param, Relation): the
% value of Param, a parameter of a frame of TID,
% is related to another datum of the dump.
data_correlation(TID, param(N, I), Relation) :-
    exception_info(TID, target, Target),
    frame_param(TID, N, I, Base),
    Offset is Target - Base,
    0 =< Offset,
    Offset < 0x1000,
    Relation = fault_at_offset(Offset).
data_correlation(TID, param(N, I), Relation) :-
    frame_param(TID, N, I, Block),
    corrupt_entry(_, Block, Finding),
    Relation = corrupt_block(Finding).
data_correlation(TID, param(N, I), Relation) :-
    frame_param(TID, N, I, Value),
    frame_param(TID, N2, I2, Value),
    N2 > N,
    Relation = shared_with(param(N2, I2)).

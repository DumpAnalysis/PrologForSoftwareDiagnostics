% 28-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 28. Sequences, Motifs, and Correlation: 28.4 Motif.
% Program block 5 of the chapter.

% window(+Len, +List, -Sub): Sub is a contiguous
% sub-sequence of List of length Len.
window(Len, List, Sub) :-
    length(Sub, Len),
    append(_, Rest, List),
    append(Sub, _, Rest).

% all_windows(+Len, -Windows): every length-Len
% window of every thread's kind sequence.
all_windows(Len, Windows) :-
    findall(Sub,
            ( trace_thread(TID),
              thread_kinds(TID, Kinds),
              window(Len, Kinds, Sub)
            ),
            Windows).

% motif(+Len, -Motif, -Count): Motif is a
% length-Len sequence of kinds occurring Count
% times, Count at least two.
motif(Len, Motif, Count) :-
    all_windows(Len, Windows),
    msort(Windows, Sorted),
    run_counts(Sorted, Counts),
    member(Motif-Count, Counts),
    Count >= 2.

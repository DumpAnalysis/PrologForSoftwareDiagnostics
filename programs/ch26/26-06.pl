% 26-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 26. Activities and Threads of Activity: 26.5 Activity Overlap.
% Program block 6 of the chapter.

% activity_overlap(SetA, SetB, From, To): the
% regions of the message sets SetA and SetB share
% the interval From..To.
activity_overlap(SetA, SetB, From, To) :-
    activity_region(SetA, FromA, ToA),
    activity_region(SetB, FromB, ToB),
    From is max(FromA, FromB),
    To is min(ToA, ToB),
    From < To.

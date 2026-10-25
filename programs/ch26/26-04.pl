% 26-04.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 26. Activities and Threads of Activity: 26.3 Activity Region.
% Program block 4 of the chapter.

% activity_region(Set, From, To): the messages of
% Set were written between From and To seconds.
activity_region(Set, From, To) :-
    Set = [First | _],
    last(Set, Last),
    msg(First, From, _, _, _, _),
    msg(Last, To, _, _, _, _).

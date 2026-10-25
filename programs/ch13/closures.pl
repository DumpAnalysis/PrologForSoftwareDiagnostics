% closures.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 13. Programs, Modules, Files, and Tooling: 13.1.1 Meta-Predicates.
% Program block 3 of the chapter.

:- module(closures,
          [ show_goal/1,
            show_plain/1,
            frames_where/3
          ]).

:- meta_predicate show_goal(0).
:- meta_predicate frames_where(+, 1, -).

show_goal(G) :- writeln(G).
show_plain(G) :- writeln(G).

%!  frames_where(+TID, :Cond, -Frames) is det.
%
%   Frames are the frames of TID for which the
%   closure Cond succeeds.
frames_where(TID, Cond, Frames) :-
    dumpkb:stack_trace(TID, All),
    include(Cond, All, Frames).

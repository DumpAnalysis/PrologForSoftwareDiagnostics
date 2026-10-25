% 11-11.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 11. The Dynamic Database, Global State, and Tabling: 11.7 Diagnostic Use.
% Program block 11 of the chapter.

% annotation(Id, Subject, Note): the analyst's
% note number Id about Subject, a term such as
% thread(TID) or module(Name).
:- dynamic annotation/3.

% annotate(Subject, Note): record Note about
% Subject under the next free identifier.
annotate(Subject, Note) :-
    flag(annotation_id, Id0, Id0 + 1),
    Id is Id0 + 1,
    assertz(annotation(Id, Subject, Note)).

% withdraw(Id): remove annotation Id.
withdraw(Id) :-
    retract(annotation(Id, _, _)).

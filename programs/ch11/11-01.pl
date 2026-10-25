% 11-01.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 11. The Dynamic Database, Global State, and Tabling: 11.1 Static and Dynamic Predicates.
% Program block 1 of the chapter.

:- [dump1].

% marked(TID): the analyst has marked TID for
% attention.
:- dynamic marked/1.

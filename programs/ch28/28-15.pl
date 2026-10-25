% 28-15.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 28. Sequences, Motifs, and Correlation: 28.14 Semantic Mapping.
% Program block 15 of the chapter.

% semantic(?Kind, ?Class): the meaning class of a
% message kind.
semantic(received, request_arrival).
semantic(dispatched, request_arrival).
semantic(completed, request_done).
semantic(query_start, db_io).
semantic(query_end, db_io).
semantic(build_start, cpu_work).
semantic(build_end, cpu_work).
semantic(resize, cpu_work).
semantic(queued, back_pressure).
semantic(error, fault).
semantic(other, other).

% mapped(?N, -Class): message N's semantic
% class.
mapped(N, Class) :-
    kind(N, Kind),
    semantic(Kind, Class).

% class_count(?Class, -Count): how many
% messages map to Class.
class_count(Class, Count) :-
    distinct(Class, semantic(_, Class)),
    aggregate_all(count, mapped(_, Class), Count).

% 24-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 24. Trace Structure: 24.2 Trace Dimension.
% Program block 3 of the chapter.

% dimension(Dim): Dim is a dimension of the trace
% along which messages are grouped.
dimension(process).
dimension(thread).
dimension(component).

% dimension_value(Dim, N, Value): message N has
% Value along dimension Dim.
dimension_value(process, N, PID) :-
    msg(N, _, PID, _, _, _).
dimension_value(thread, N, TID) :-
    msg(N, _, _, TID, _, _).
dimension_value(component, N, C) :-
    msg(N, _, _, _, C, _).

% trace_dimension(Dim, Values): Values is the set
% of values occurring along Dim.
trace_dimension(Dim, Values) :-
    dimension(Dim),
    aggregate_all(set(V),
                  dimension_value(Dim, _, V),
                  Values).

% dimension_size(Dim, Size): Size is the number of
% distinct values along Dim.
dimension_size(Dim, Size) :-
    trace_dimension(Dim, Values),
    length(Values, Size).

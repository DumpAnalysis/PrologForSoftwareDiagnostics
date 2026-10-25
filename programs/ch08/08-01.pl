% 08-01.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 8. Atoms, Strings, and Term Inspection: 8.4 Term Inspection.
% Program block 1 of the chapter.

% frame_field(Name, Index): argument Index of a
% frame/5 term holds the field Name.
frame_field(tid, 1).
frame_field(number, 2).
frame_field(module, 3).
frame_field(function, 4).
frame_field(offset, 5).

% field_of(Frame, Name, Value): Value is the field
% Name of the frame/5 term Frame.
field_of(Frame, Name, Value) :-
    functor(Frame, frame, 5),
    frame_field(Name, Index),
    arg(Index, Frame, Value).

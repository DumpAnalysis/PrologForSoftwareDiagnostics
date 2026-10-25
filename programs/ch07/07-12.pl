% 07-12.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 7. Control: 7.7 Diagnostic Use.
% Program block 12 of the chapter.

% lookup_class(TID, Class): as thread_class/2 for
% a bound TID; an error on a non-integer or an
% absent TID.
lookup_class(TID, Class) :-
    must_be(integer, TID),
    (   thread(TID, _)
    ->  class_of(TID, Class)
    ;   existence_error(thread, TID)
    ).

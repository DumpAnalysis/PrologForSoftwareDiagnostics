% 07-09.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 7. Control: 7.6 Exceptions.
% Program block 9 of the chapter.

% call_missing(E): E is the formal error term
% raised by a goal for an undefined predicate.
call_missing(E) :-
    catch(missing(1), error(E, _), true).

% 08-04.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 8. Atoms, Strings, and Term Inspection: 8.5 Diagnostic Use.
% Program block 4 of the chapter.

% scoped_name(Function, Scope, Name): Function is
% Scope::Name, split at the last scope operator.
scoped_name(Function, Scope, Name) :-
    once(( sub_atom(Function, B, 2, A, '::'),
           sub_atom(Function, _, A, 0, Name),
           \+ sub_atom(Name, _, _, _, '::')
         )),
    sub_atom(Function, 0, B, _, Scope).

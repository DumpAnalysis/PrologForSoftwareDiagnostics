% 03-03.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 3. Unification: 3.7 Diagnostic Use.
% Program block 3 of the chapter.

% frame_matches(Name, TID, N): frame N of thread
% TID is an instance of the template called Name.
frame_matches(Name, TID, N) :-
    template(Name, Template),
    frame(TID, N, M, F, O),
    Frame = frame(TID, N, M, F, O),
    subsumes_term(Template, Frame).

% 17-09.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 17. The Pattern as a Predicate: 17.6 The Catalog as Data.
% Program block 9 of the chapter.

% pattern_instances(Evidence): Evidence is the
% list of evidence terms of every pattern instance
% that a recognizer in the catalog finds.
pattern_instances(Evidence) :-
    findall(E,
            ( recognizer(_, Recognizer),
              call(Recognizer, _, E)
            ),
            Evidence).

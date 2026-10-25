% 24-13.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 24. Trace Structure: 24.11 Trace Mask.
% Program block 13 of the chapter.

% trace_mask(Hidden, Visible): Visible is the set
% of messages not written by a component in the
% list Hidden.
trace_mask(Hidden, Visible) :-
    findall(N,
            ( msg(N, _, _, _, C, _),
              \+ memberchk(C, Hidden) ),
            Ns),
    sort(Ns, Visible).

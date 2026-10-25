% 27-12.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.11 Anchor Messages.
% Program block 12 of the chapter.

% anchor_messages(-Ns): Ns are the anchors of the
% trace, the request arrivals.
anchor_messages(Ns) :-
    findall(N, prefix_of("Request # received", N),
            Ns).

% anchored(+Anchor, -Ns): the messages from Anchor
% up to, not including, the next anchor.
anchored(Anchor, Ns) :-
    anchor_messages(Anchors),
    memberchk(Anchor, Anchors),
    (   aggregate_all(min(A),
                      ( member(A, Anchors),
                        A > Anchor
                      ),
                      Next)
    ->  true
    ;   aggregate_all(max(N), text_of(N, _),
                      Last),
        Next is Last + 1
    ),
    End is Next - 1,
    numlist(Anchor, End, Ns).

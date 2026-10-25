% 24-20.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 24. Trace Structure: 24.18 Message Directory.
% Program block 20 of the chapter.

% message_directory(Directory): Directory is the
% list of Kind-Set pairs, one per message kind, in
% the standard order of the kinds; each Set is in
% message order.
message_directory(Directory) :-
    findall(Kind-N, message_kind(N, Kind), Pairs),
    sort(Pairs, Sorted),
    group_pairs_by_key(Sorted, Directory).

% print_directory(Directory): one line per kind
% with its count and first occurrence.
print_directory(Directory) :-
    forall(member(Kind-Ns, Directory),
           ( length(Ns, Count),
             Ns = [First | _],
             truncated(Kind, 40, Short),
             format("~t~d~3| ~t~d~7| ~s~n",
                    [Count, First, Short]) )).

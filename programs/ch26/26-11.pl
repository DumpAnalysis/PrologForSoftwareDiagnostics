% 26-11.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 26. Activities and Threads of Activity: 26.10 Glued Activity.
% Program block 11 of the chapter.

% boundary(N): message N begins a new piece of
% work on its thread.
boundary(N) :-
    msg(N, _, _, _, _, Text),
    sub_string(Text, 0, _, _, "Request "),
    sub_string(Text, _, _, _, " dispatched").

% activity_parts(Set, Parts): Parts divides the
% message set Set at its boundary messages, each
% part beginning with one except possibly the
% first.
activity_parts([], []).
activity_parts([N | Ns], [[N | Part] | Parts]) :-
    take_part(Ns, Part, Rest),
    activity_parts(Rest, Parts).

take_part(Ns, Part, Rest) :-
    (   Ns = [N | Ns1],
        \+ boundary(N)
    ->  Part = [N | Part1],
        take_part(Ns1, Part1, Rest)
    ;   Part = [],
        Rest = Ns
    ).

% glued_activity(TID, Parts): the activity of
% thread TID consists of at least two parts.
glued_activity(TID, Parts) :-
    thread_of_activity(TID, Set),
    activity_parts(Set, Parts),
    Parts = [_, _ | _].

% print_parts(Parts): one line per part with its
% message range and size.
print_parts(Parts) :-
    forall(member(Part, Parts),
           ( Part = [First | _],
             last(Part, Last),
             length(Part, Count),
             format("~t~d~3|-~d~t~7| ~t~d~10|~n",
                    [First, Last, Count]) )).

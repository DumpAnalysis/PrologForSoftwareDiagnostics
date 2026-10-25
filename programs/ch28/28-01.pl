% 28-01.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 28. Sequences, Motifs, and Correlation.
% Program block 1 of the chapter.

:- [trace1].

% text_of(?N, ?Text): the text of message N.
text_of(N, Text) :-
    msg(N, _, _, _, _, Text).

% invariant(+Text, -Inv): Text with every number
% replaced by #, as in Chapter 27.
invariant(Text, Inv) :-
    string_codes(Text, Codes),
    blank_numbers(Codes, Skeleton),
    string_codes(Inv, Skeleton).

blank_numbers([], []).
blank_numbers([C|Cs], Skeleton) :-
    (   code_type(C, digit)
    ->  skip_number(Cs, Rest),
        Skeleton = [0'#|Skeleton1],
        blank_numbers(Rest, Skeleton1)
    ;   Skeleton = [C|Skeleton1],
        blank_numbers(Cs, Skeleton1)
    ).

skip_number(Cs, Rest) :-
    (   Cs = [C|Cs1],
        (   code_type(C, alnum)
        ;   C == 0'.
        )
    ->  skip_number(Cs1, Rest)
    ;   Rest = Cs
    ).

% kind(?N, ?Kind): the kind atom of message N.
kind(N, Kind) :-
    text_of(N, Text),
    invariant(Text, Inv),
    kind_of(Inv, Kind).

% kind_prefix(?Kind, ?Prefix): a message whose
% invariant begins with Prefix is of kind Kind.
kind_prefix(received, "Request # received").
kind_prefix(dispatched, "Request # dispatched").
kind_prefix(completed, "Request # completed").
kind_prefix(query_start, "Query start").
kind_prefix(query_end, "Query end").
kind_prefix(build_start, "Build start").
kind_prefix(build_end, "Build end").
kind_prefix(resize, "Warning: table").
kind_prefix(queued, "No idle").
kind_prefix(error, "Error:").

% kind_of(+Inv, ?Kind): Kind is the kind whose
% prefix Inv begins with, or other if none does.
% The kind is found in a fresh variable and
% unified with Kind only after the commitment.
kind_of(Inv, Kind) :-
    (   kind_prefix(Kind0, Prefix),
        sub_string(Inv, 0, _, _, Prefix)
    ->  Kind = Kind0
    ;   Kind = other
    ).

% trace_thread(-TID): every thread, once each.
trace_thread(TID) :-
    distinct(TID, msg(_, _, _, TID, _, _)).

% thread_sequence(+TID, -Ns): message numbers of
% thread TID in order.
thread_sequence(TID, Ns) :-
    findall(N, msg(N, _, _, TID, _, _), Ns0),
    sort(Ns0, Ns).

% thread_kinds(+TID, -Kinds): the kinds of thread
% TID's messages in order.
thread_kinds(TID, Kinds) :-
    thread_sequence(TID, Ns),
    maplist(kind, Ns, Kinds).

% print_messages(+Ns): one line per message.
print_messages(Ns) :-
    forall(member(N, Ns), print_msg(N)).

print_msg(N) :-
    msg(N, _, _, TID, _, Text),
    format("~t~d~3| ~d ~s~n", [N, TID, Text]).

% print_kinds(+Ks): the kinds of a sequence, one
% per line with its position, so a long sequence
% stays within the page.
print_kinds(Ks) :-
    forall(nth1(I, Ks, K),
           format("~t~d~3| ~a~n", [I, K])).

% run_counts(+Sorted, -Counts): X-N per run of N
% equal elements X, as in Chapter 9.
run_counts([], []).
run_counts([X|Xs], [X-N|Counts]) :-
    run_length(Xs, X, 1, N, Rest),
    run_counts(Rest, Counts).

run_length(Xs, X, N0, N, Rest) :-
    (   Xs = [Y|Xs1],
        Y == X
    ->  N1 is N0 + 1,
        run_length(Xs1, X, N1, N, Rest)
    ;   N = N0,
        Rest = Xs
    ).

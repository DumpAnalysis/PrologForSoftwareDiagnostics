% 23-12.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 23. Dump Quality, Composition, and Reports: 23.10 The Analysis Report.
% Program block 12 of the chapter.

% describe(Instance, Format, Args): how to print
% an instance of each kind.
describe(thread(T), "thread ~d", [T]).
describe(thread(T, Kind), "thread ~d (~a)",
         [T, Kind]).
describe(threads(Ts), "threads ~w", [Ts]).
describe(chain(Chain), "wait chain ~w", [Chain]).
describe(module(M), "module ~a", [M]).
describe(heap(H), "heap 0x~16r", [H]).
describe(process, "the process", []).
describe(process(PID), "process ~d", [PID]).
describe(handles(Type), "~a handles", [Type]).
describe(hook(F, M, H), "~a!~a <- ~a", [M, F, H]).
describe(frames(T, _-F, N),
         "thread ~d: ~d frames of ~a", [T, N, F]).
describe(error(T, C),
         "thread ~d: last error 0x~16r", [T, C]).
describe(dumps(Ds), "dumps ~w", [Ds]).

% print_instance(Instance): one indented line.
print_instance(Instance) :-
    (   describe(Instance, Format, Args)
    ->  format("    "),
        format(Format, Args),
        nl
    ;   format("    ~w~n", [Instance])
    ).

% recognized(Rank, Pattern): Pattern has at least
% one instance.
recognized(Rank, Pattern) :-
    severity(Pattern, Rank),
    once(instance(Pattern, _)).

% report_pattern(Rank, Pattern): the heading, the
% instances, and the entailments of Pattern.
report_pattern(Rank, Pattern) :-
    rank_name(Rank, Word),
    format("[~a] ~a~n", [Word, Pattern]),
    forall(instance(Pattern, Instance),
           print_instance(Instance)),
    forall(implies(Other, Pattern),
           format("    (entailed by ~a)~n",
                  [Other])).

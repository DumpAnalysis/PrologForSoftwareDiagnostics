% 22-19.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 22. Modules, Versions, and Environment: 22.20 Ubiquitous Component.
% Program block 19 of the chapter.

% on_stack_of(Module, TID): Module has a frame on
% the stack trace of TID.
on_stack_of(Module, TID) :-
    distinct(TID, frame(TID, _, Module, _, _)).

% ubiquitous_component(Module): Module is on the
% stack traces of at least the ubiquity share of
% the threads.
ubiquitous_component(Module) :-
    module(Module, _, _),
    aggregate_all(count, thread(_, _), Threads),
    aggregate_all(count, on_stack_of(Module, _),
                  OnStack),
    threshold(ubiquity, Share),
    OnStack / Threads >= Share.

% thread_count(Module, N): Module is on N stack
% traces.
thread_count(Module, N) :-
    module(Module, _, _),
    aggregate_all(count, on_stack_of(Module, _),
                  N).

% print_ubiquity: every module with the number of
% threads it appears on, most first.
print_ubiquity :-
    forall(order_by([desc(N)],
                    thread_count(M, N)),
           format("~a~t~17|~t~d~3+~n", [M, N])).

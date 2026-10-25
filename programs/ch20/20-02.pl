% 20-02.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 20. Synchronization Patterns.
% Program block 2 of the chapter.

% The two extension relations are dynamic, so that
% the boundary checks of Section 20.5 can add
% facts and take them away again.
:- dynamic mutant/3, waits_for_object/3.

% mutant(Handle, OwnerTID, Name): a mutex object
% with its owner. An extension of the schema.
mutant(0x1a8, 120, 'AppServer.CacheMutex').
mutant(0x1b4, 123, 'AppServer.LogMutex').

% waits_for_object(TID, Kind, Object): as
% waits_for/3, for Kinds mutant and thread. An
% extension of the schema.
waits_for_object(120, thread, 103).
waits_for_object(121, mutant, 0x1a8).
waits_for_object(122, thread, 121).
waits_for_object(123, thread, 124).
waits_for_object(124, mutant, 0x1b4).

% wait_fact(TID, Kind, Object, Fact): Fact is the
% fact, of the shared file or of the extension,
% that records that TID waits for Object of Kind.
wait_fact(T, K, O, waits_for(T, K, O)) :-
    waits_for(T, K, O).
wait_fact(T, K, O, waits_for_object(T, K, O)) :-
    waits_for_object(T, K, O).

% waits(TID, Kind, Object): TID waits for Object
% of Kind, by the shared facts or the extension.
waits(TID, Kind, Object) :-
    wait_fact(TID, Kind, Object, _).

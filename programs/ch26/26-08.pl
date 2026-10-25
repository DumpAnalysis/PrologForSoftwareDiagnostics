% 26-08.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 26. Activities and Threads of Activity: 26.7 Fiber Bundle.
% Program block 8 of the chapter.

% fiber_bundle(Key, Bundle): Bundle is the list of
% TID-Fiber pairs of the adjoint thread Key.
fiber_bundle(Key, Bundle) :-
    findall(TID-Fiber,
            fiber_of_activity(TID, Key, Fiber),
            Bundle).

% print_bundle(Bundle): one line per fiber.
print_bundle(Bundle) :-
    forall(member(TID-Fiber, Bundle),
           format("~d~t~6|~w~n", [TID, Fiber])).

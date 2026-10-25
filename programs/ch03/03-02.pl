% 03-02.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 3. Unification: 3.7 Diagnostic Use.
% Program block 2 of the chapter.

% blocked_thread(TID): TID is blocked entering a
% critical section.
blocked_thread(TID) :-
    frame(TID, _, ntdll,
          'RtlEnterCriticalSection', _).

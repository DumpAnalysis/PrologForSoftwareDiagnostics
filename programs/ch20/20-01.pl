% 20-01.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 20. Synchronization Patterns.
% Program block 1 of the chapter.

:- [dump1].

% threshold(Name, Value): the thresholds.
threshold(queue_length, 2).
threshold(contention, 2).
threshold(swarm_size, 4).
threshold(spiking_share, 25).

% system_module(M): M belongs to the operating
% system or a runtime, not to the application.
system_module(ntdll).
system_module(kernelbase).
system_module(kernel32).
system_module(ucrtbase).
system_module(msvcp140).

% pattern(Name, Artifact, Chapter): the patterns
% this chapter recognizes with a predicate.
pattern('Wait Chain (Critical Sections)',
        memory_dump, 20).
pattern('Wait Chain (Mutex Objects)',
    memory_dump, 20).
pattern('Wait Chain (Thread Objects)',
    memory_dump, 20).
pattern('Deadlock (Critical Sections)',
    memory_dump, 20).
pattern('Deadlock (Mixed Objects)',
    memory_dump, 20).
pattern('Blocked Queue', memory_dump, 20).
pattern('High Contention (Critical Sections)',
        memory_dump, 20).
pattern('Critical Section Corruption',
    memory_dump, 20).
pattern('Swarm of Shared Locks', memory_dump, 20).
pattern('Waiting Thread Time', memory_dump, 20).
pattern('Thread Starvation (Normal Priority)',
        memory_dump, 20).
pattern('Blocking Module', memory_dump, 20).

% 22-18.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 22. Modules, Versions, and Environment: 22.18 Zombie Processes, Special Process, Frozen Process, and Busy System.
% Program block 18 of the chapter.

% sys_process(PID, Name, Threads, State): a
% process of a kernel or complete memory dump,
% with its thread count and state. An extension of
% the schema for dumps that hold many processes.
sys_process(4, 'System', 180, active).
sys_process(512, 'smss.exe', 2, active).
sys_process(600, 'csrss.exe', 12, active).
sys_process(700, 'lsass.exe', 9, active).
sys_process(4120, 'AppServer.exe', 10, active).
sys_process(5200, 'Updater.exe', 0, exited).
sys_process(5300, 'Monitor.exe', 6, frozen).

% processor(Cpu, PID): the process whose thread
% was running on Cpu, or idle.
processor(0, 4120).
processor(1, 4120).
processor(2, 700).
processor(3, 4).

% zombie_processes(PID): a process that has exited
% but whose process object remains.
zombie_processes(PID) :-
    sys_process(PID, _, 0, exited).

% special_name(Name): a process on which the
% system depends.
special_name('System').
special_name('smss.exe').
special_name('csrss.exe').
special_name('lsass.exe').
special_name('services.exe').
special_name('wininit.exe').

% special_process(PID): a process of the system.
special_process(PID) :-
    sys_process(PID, Name, _, _),
    special_name(Name).

% frozen_process(PID): a process whose threads are
% all frozen.
frozen_process(PID) :-
    sys_process(PID, _, Threads, frozen),
    Threads > 0.

% busy_system: no processor was idle.
busy_system :-
    \+ processor(_, idle).

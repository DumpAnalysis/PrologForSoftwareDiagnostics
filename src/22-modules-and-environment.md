# Chapter 22. Modules, Versions, and Environment

Code and transcripts of this chapter of *Prolog for Pattern-Oriented Software Diagnostics*, with the prose removed. Replay with `python3 tools/verify.py src/22-modules-and-environment.md`.

```{.prolog .program}
:- [dump1].

% pattern(Name, Artifact, Chapter): the catalog
% entries treated in this chapter.
pattern('Module Variety', memory_dump, 22).
pattern('Not My Version', memory_dump, 22).
pattern('Unknown Component', memory_dump, 22).
pattern('No Component Symbols', memory_dump, 22).
pattern('Missing Component (General)',
    memory_dump, 22).
pattern('Hooked Functions (User Space)',
    memory_dump, 22).
pattern('Hooked Modules', memory_dump, 22).
pattern('Hidden Module', memory_dump, 22).
pattern('Changed Environment', memory_dump, 22).
pattern('Virtualized Process (WOW64)',
    memory_dump, 22).
pattern('Deviant Module', memory_dump, 22).
pattern('Same Vendor', memory_dump, 22).
pattern('Top Module', memory_dump, 22).
pattern('Origin Module', memory_dump, 22).
pattern('Module Hint', memory_dump, 22).
pattern('Historical Information',
    memory_dump, 22).
pattern('Last Error Collection', memory_dump, 22).
pattern('Zombie Processes', memory_dump, 22).
pattern('Special Process', memory_dump, 22).
pattern('Frozen Process', memory_dump, 22).
pattern('Busy System', memory_dump, 22).
pattern('Lateral Damage', memory_dump, 22).
pattern('Ubiquitous Component', memory_dump, 22).

% threshold(Name, Value): the analyst's limits.
threshold(ubiquity, 0.7).

% system_module(Module): a module supplied by the
% operating system or the C runtime. An extension
% of the schema: the analyst's knowledge.
system_module(ntdll).
system_module(kernelbase).
system_module(kernel32).
system_module(ucrtbase).
system_module(msvcp140).

% vendor(Module, Vendor): the company recorded for
% Module; system for a system module without one;
% unrecorded otherwise.
vendor(Module, Vendor) :-
    module(Module, _, _),
    (   module_info(Module, company, Company)
    ->  Vendor = Company
    ;   system_module(Module)
    ->  Vendor = system
    ;   Vendor = unrecorded
    ).
```

```{.prolog .query}
?- set_prolog_flag(toplevel_print_anon, false).
true.

?- aggregate_all(count, pattern(_, _, 22), N).
N = 23.

?- vendor(dbclient, V).
V = 'Example Corp'.

?- vendor(ntdll, V).
V = system.
```

## 22.1 Module Variety

```{.prolog .program}
% module_variety(Count): the number of modules
% loaded in the process.
module_variety(Count) :-
    aggregate_all(count, module(_, _, _), Count).

% third_party_ratio(Ratio): the share of loaded
% modules that are not system modules.
third_party_ratio(Ratio) :-
    module_variety(Total),
    aggregate_all(count,
                  ( module(M, _, _),
                    \+ system_module(M)
                  ),
                  Others),
    Ratio is Others / Total.

% vendor_variety(Vendors): the set of vendors of
% the loaded modules.
vendor_variety(Vendors) :-
    aggregate_all(set(V), vendor(_, V), Vendors).
```

```{.prolog .query}
?- module_variety(N), third_party_ratio(R).
N = 10,
R = 0.5.

?- vendor_variety(_Vs),
   forall(member(V, _Vs), format("~a~n", [V])).
CacheWorks
Example Corp
Unknown
system
true.

?- aggregate(count, M^vendor(M, V), N).
V = 'CacheWorks',
N = 1 ;
V = 'Example Corp',
N = 3 ;
V = 'Unknown',
N = 1 ;
V = system,
N = 5.
```

## 22.2 Not My Version

```{.prolog .program}
% version_parts(Version, Parts): the numbers of a
% dotted version atom, as a list.
version_parts(Version, Parts) :-
    atomic_list_concat(Texts, '.', Version),
    maplist(atom_number, Texts, Parts).

% main_module(Module): the module of the process's
% executable, by its file name.
main_module(Module) :-
    process(_, Executable),
    file_name_extension(Base, _, Executable),
    downcase_atom(Base, Module),
    module(Module, _, _).

% version_of(Module, Parts): the version of Module
% as a list of numbers; a module has one version.
version_of(Module, Parts) :-
    once(module_info(Module, version, Version)),
    version_parts(Version, Parts).

% not_my_version(Module): Module is from the same
% vendor as the executable but has a different
% version.
not_my_version(Module) :-
    main_module(Main),
    vendor(Main, Vendor),
    vendor(Module, Vendor),
    Module \== Main,
    version_of(Main, MainParts),
    version_of(Module, Parts),
    MainParts \== Parts.

% older_than(M1, M2): the version of M1 precedes
% that of M2.
older_than(M1, M2) :-
    version_of(M1, P1),
    version_of(M2, P2),
    P1 @< P2.
```

```{.prolog .query}
?- version_parts('3.1.0.7', P).
P = [3, 1, 0, 7].

?- '3.10.0.0' @< '3.9.0.0'.
true.

?- version_parts('3.10.0.0', A),
   version_parts('3.9.0.0', B), A @< B.
false.

?- main_module(M).
M = appserver.

?- not_my_version(M).
M = dbclient ;
false.

?- older_than(dbclient, appserver).
true.
```

## 22.3 Unknown Component

```{.prolog .program}
% unknown_component(Module): the dump records no
% vendor for Module, or records it as unknown.
unknown_component(Module) :-
    vendor(Module, Vendor),
    memberchk(Vendor, ['Unknown', unrecorded]).
```

```{.prolog .query}
?- unknown_component(M).
M = thirdparty_hook.

?- unknown_component(M), module_info(M, K, V).
M = thirdparty_hook,
K = version,
V = '1.0.0.1' ;
M = thirdparty_hook,
K = symbols,
V = none ;
M = thirdparty_hook,
K = company,
V = 'Unknown'.
```

## 22.4 No Component Symbols

```{.prolog .program}
% no_component_symbols(Module): the debugger had
% no symbol file for Module.
no_component_symbols(Module) :-
    module_info(Module, symbols, Kind),
    Kind \== pdb.
```

```{.prolog .query}
?- no_component_symbols(M).
M = dbclient ;
M = cachelib ;
M = thirdparty_hook.

?- frame(T, N, M, 'Unknown', O).
T = 101,
N = 4,
M = cachelib,
O = 10768.

?- forall(frame(_, _, M, 'Unknown', _),
          no_component_symbols(M)).
true.

?- no_component_symbols(M),
   \+ frame(_, _, M, 'Unknown', _).
M = dbclient ;
M = thirdparty_hook.
```

## 22.5 Missing Component (General)

```{.prolog .program}
% expected_module(Module): the modules the product
% deploys. An extension of the schema: knowledge
% about the product, not content of the dump.
expected_module(appserver).
expected_module(reportengine).
expected_module(dbclient).
expected_module(cachelib).
expected_module(authplugin).

% missing_component(Module): an expected module is
% not loaded.
missing_component(Module) :-
    expected_module(Module),
    \+ module(Module, _, _).
```

```{.prolog .query}
?- missing_component(M).
M = authplugin.

?- expected_module(M), module(M, _, _),
   format("~a~n", [M]), fail.
appserver
reportengine
dbclient
cachelib
false.
```

## 22.6 Hooked Functions (User Space)

```{.prolog .program}
% hooked_functions(Module, Hooker, Functions): the
% functions of Module that Hooker hooks.
hooked_functions(Module, Hooker, Functions) :-
    bagof(Function,
          hooked(Function, Module, Hooker),
          Functions).
```

```{.prolog .query}
?- hooked_functions(M, H, Fs).
M = kernelbase,
H = thirdparty_hook,
Fs = ['CreateFileW', 'ReadFile'].

?- hooked_functions(kernelbase, _, Fs),
   length(Fs, N).
Fs = ['CreateFileW', 'ReadFile'],
N = 2.
```

## 22.7 Hooked Modules

```{.prolog .program}
% hooked_modules(Module): some function of Module
% is hooked.
hooked_modules(Module) :-
    distinct(Module, hooked(_, Module, _)).

% hooking_module(Hooker): Hooker hooks a function
% of some module.
hooking_module(Hooker) :-
    distinct(Hooker, hooked(_, _, Hooker)).
```

```{.prolog .query}
?- hooked_modules(M).
M = kernelbase ;
false.

?- hooking_module(H), unknown_component(H),
   no_component_symbols(H).
H = thirdparty_hook ;
false.
```

## 22.8 Hidden Module

```{.prolog .program}
% code_region(Base, Size): a region of executable
% memory in the address space. An extension of the
% schema.
code_region(0x0000_7ffb_b2a0_0000, 0x1f8000).
code_region(0x0000_7ff6_1d10_0000, 0x3c000).
code_region(0x0000_0210_c000_0000, 0x8000).

% hidden_module(Base, Size): an executable region
% that no loaded module covers.
hidden_module(Base, Size) :-
    code_region(Base, Size),
    \+ ( module(_, ModBase, ModSize),
         ModBase =< Base,
         Base + Size =< ModBase + ModSize
       ).
```

```{.prolog .query}
?- hidden_module(B, S),
   format("~16r ~16r~n", [B, S]).
210c0000000 8000
B = 2270963957760,
S = 32768.

?- code_region(B, _), module(M, B, _).
B = 140719010349056,
M = ntdll ;
B = 140695026270208,
M = appserver ;
false.
```

## 22.9 Changed Environment

```{.prolog .program}
% env(Name, Value): the environment block of the
% process. An extension of the schema.
env('COMPUTERNAME', 'APP01').
env('APP_ENV', staging).
env('COR_ENABLE_PROFILING', '1').
env('TMP', 'C:\\Windows\\Temp').

% expected_env(Name, Value): the baseline the
% analyst compares with; absent means the variable
% must not be set. An extension of the schema.
expected_env('APP_ENV', production).
expected_env('APP_HOME', 'C:\\App').
expected_env('COR_ENABLE_PROFILING', absent).
expected_env('TMP', 'C:\\Windows\\Temp').

% changed_environment(Name, Change): the variable
% Name differs from the baseline: changed, added,
% or removed.
changed_environment(Name, changed(Old, New)) :-
    expected_env(Name, Old),
    Old \== absent,
    env(Name, New),
    New \== Old.
changed_environment(Name, added(Value)) :-
    expected_env(Name, absent),
    env(Name, Value).
changed_environment(Name, removed(Old)) :-
    expected_env(Name, Old),
    Old \== absent,
    \+ env(Name, _).
```

```{.prolog .query}
?- changed_environment(N, C).
N = 'APP_ENV',
C = changed(production, staging) ;
N = 'COR_ENABLE_PROFILING',
C = added('1') ;
N = 'APP_HOME',
C = removed('C:\\App') ;
false.

?- env('TMP', V), expected_env('TMP', V).
V = 'C:\\Windows\\Temp'.
```

## 22.10 Virtualized Process (WOW64)

```{.prolog .program}
% process_info(Key, Value): properties of the
% process. An extension of the schema.
process_info(wow64, false).
process_info(pointer_size, 8).

% virtualized_process: the process runs 32-bit
% code under the system's WOW64 layer, by the
% debugger's report or by the layer's modules.
virtualized_process :-
    (   process_info(wow64, true)
    ;   module(wow64, _, _)
    ).
```

```{.prolog .query}
?- virtualized_process.
false.

?- process_info(pointer_size, S),
   module(_, Base, _), Base >= 1 << 32.
S = 8,
Base = 140719010349056 ;
S = 8,
Base = 140718977843200 ;
...
```

## 22.11 Deviant Module

```{.prolog .program}
% deviant_module(Module, Key): among at least
% three modules of one vendor, Module alone has
% its value of Key.
deviant_module(Module, Key) :-
    vendor(Module, Vendor),
    aggregate_all(count, vendor(_, Vendor), N),
    N >= 3,
    module_info(Module, Key, Value),
    forall(( vendor(Other, Vendor),
             Other \== Module
           ),
           ( module_info(Other, Key, OtherValue),
             OtherValue \== Value
           )).
```

```{.prolog .query}
?- deviant_module(M, K).
M = dbclient,
K = version ;
M = dbclient,
K = symbols ;
false.

?- deviant_module(M, K), module_info(M, K, V).
M = dbclient,
K = version,
V = '3.1.0.7' ;
M = dbclient,
K = symbols,
V = export ;
false.
```

## 22.12 Same Vendor

```{.prolog .program}
% stack_module(TID, Module): a non-system module
% with a frame on the stack trace of TID.
stack_module(TID, Module) :-
    frame(TID, _, Module, _, _),
    \+ system_module(Module).

% same_vendor(TID, Vendor, Modules): the two or
% more non-system modules on the stack trace of
% TID all come from Vendor.
same_vendor(TID, Vendor, Modules) :-
    thread(TID, _),
    setof(M, stack_module(TID, M), Modules),
    Modules = [_, _ | _],
    maplist(from_vendor(Vendor), Modules).

from_vendor(Vendor, Module) :-
    vendor(Module, Vendor).
```

```{.prolog .query}
?- same_vendor(T, V, Ms).
T = 102,
V = 'Example Corp',
Ms = [appserver, reportengine] ;
T = 103,
V = 'Example Corp',
Ms = [appserver, dbclient] ;
T = 104,
V = 'Example Corp',
Ms = [appserver, dbclient] ;
T = 107,
V = 'Example Corp',
Ms = [appserver, reportengine] ;
T = 109,
V = 'Example Corp',
Ms = [appserver, dbclient].

?- setof(M, stack_module(101, M), Ms).
Ms = [appserver, cachelib].
```

## 22.13 Top Module

```{.prolog .program}
% top_module(TID, Module): the module of the top
% frame of TID.
top_module(TID, Module) :-
    frame(TID, 0, Module, _, _).
```

```{.prolog .query}
?- aggregate_all(count, top_module(_, ntdll), N).
N = 7.

?- top_module(T, M), \+ system_module(M).
T = 102,
M = reportengine ;
T = 107,
M = reportengine ;
T = 109,
M = dbclient.
```

## 22.14 Origin Module

```{.prolog .program}
% origin_module(TID, Module): the module of the
% deepest non-system frame of TID.
origin_module(TID, Module) :-
    thread(TID, _),
    aggregate_all(max(N, M),
                  ( frame(TID, N, M, _, _),
                    \+ system_module(M)
                  ),
                  max(_, Module)).
```

```{.prolog .query}
?- origin_module(T, M).
T = 100,
M = appserver ;
T = 101,
M = appserver ;
T = 102,
M = appserver ;
T = 103,
M = appserver ;
T = 104,
M = dbclient ;
T = 107,
M = appserver ;
T = 108,
M = appserver ;
T = 109,
M = appserver.

?- frame(104, N, dbclient, F, _).
N = 5,
F = 'Connection::OnReply' ;
N = 6,
F = 'Reader::Loop'.
```

## 22.15 Module Hint

```{.prolog .program}
% hint_word(Word, Hint): a word in a module name
% and what it suggests.
hint_word(hook, hooking).
hint_word(inject, injection).
hint_word(guard, protection).
hint_word(shim, compatibility).
hint_word(cache, caching).

% module_hint(Module, Hint): the name of Module
% contains a hint word.
module_hint(Module, Hint) :-
    module(Module, _, _),
    hint_word(Word, Hint),
    sub_atom(Module, _, _, _, Word).
```

```{.prolog .query}
?- module_hint(M, H).
M = cachelib,
H = caching ;
M = thirdparty_hook,
H = hooking ;
false.
```

## 22.16 Historical Information

## 22.17 Last Error Collection

```{.prolog .program}
% win32_error(Code, Name): the names of some Win32
% error codes.
win32_error(0x0, 'ERROR_SUCCESS').
win32_error(0x2, 'ERROR_FILE_NOT_FOUND').
win32_error(0x5, 'ERROR_ACCESS_DENIED').
win32_error(0x6, 'ERROR_INVALID_HANDLE').
win32_error(0x8, 'ERROR_NOT_ENOUGH_MEMORY').
win32_error(0x57, 'ERROR_INVALID_PARAMETER').
win32_error(0x7e, 'ERROR_MOD_NOT_FOUND').
win32_error(0x3e6, 'ERROR_NOACCESS').

% error_name(Code, Name): the name of Code, or
% unknown.
error_name(Code, Name) :-
    (   win32_error(Code, Name)
    ->  true
    ;   Name = unknown
    ).

% last_error_collection(Collection): the TID-Code
% pairs of every thread with a recorded last
% error, by thread.
last_error_collection(Collection) :-
    findall(TID-Code, last_error(TID, Code),
            Pairs),
    keysort(Pairs, Collection).

% print_last_errors: one line per recorded thread.
print_last_errors :-
    last_error_collection(Collection),
    forall(member(TID-Code, Collection),
           ( error_name(Code, Name),
             format("~d~t~6|~16r~t~12|~a~n",
                    [TID, Code, Name])
           )).
```

```{.prolog .query}
?- print_last_errors.
100   0     ERROR_SUCCESS
101   0     ERROR_SUCCESS
102   0     ERROR_SUCCESS
103   0     ERROR_SUCCESS
104   0     ERROR_SUCCESS
109   3e6   ERROR_NOACCESS
true.

?- last_error_collection(_C),
   member(T-C, _C), C =\= 0.
T = 109,
C = 998.

?- thread(T, _), \+ last_error(T, _).
T = 105 ;
T = 106 ;
T = 107 ;
T = 108 ;
false.
```

## 22.18 Zombie Processes, Special Process, Frozen Process, and Busy System

```{.prolog .program}
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
```

```{.prolog .query}
?- zombie_processes(P), sys_process(P, N, _, _).
P = 5200,
N = 'Updater.exe'.

?- special_process(P), sys_process(P, N, _, _).
P = 4,
N = 'System' ;
P = 512,
N = 'smss.exe' ;
P = 600,
N = 'csrss.exe' ;
P = 700,
N = 'lsass.exe' ;
false.

?- frozen_process(P).
P = 5300.

?- busy_system.
true.
```

## 22.19 Lateral Damage

## 22.20 Ubiquitous Component

```{.prolog .program}
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
```

```{.prolog .query}
?- print_ubiquity.
ntdll             10
kernel32          10
appserver          8
ucrtbase           6
dbclient           3
kernelbase         2
reportengine       2
cachelib           1
msvcp140           0
thirdparty_hook    0
true.

?- ubiquitous_component(M).
M = ntdll ;
M = kernel32 ;
M = appserver ;
false.

?- ubiquitous_component(M), \+ system_module(M).
M = appserver ;
false.
```

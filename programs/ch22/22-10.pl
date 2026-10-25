% 22-10.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 22. Modules, Versions, and Environment: 22.9 Changed Environment.
% Program block 10 of the chapter.

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

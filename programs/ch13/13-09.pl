% 13-09.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 13. Programs, Modules, Files, and Tooling: 13.4 CSV, JSON, and Regular Expressions.
% Program block 9 of the chapter.

:- use_module(library(pcre)).

% completion(Text, Request, Ms): Text reports the
% completion of Request after Ms milliseconds.
completion(Text, Request, Ms) :-
    re_matchsub("^Request (?<r_I>\\d+) \c
                 completed: (?<s_I>\\d+), \c
                 (?<ms_I>\\d+) ms$",
                Text, Sub, []),
    get_dict(r, Sub, Request),
    get_dict(ms, Sub, Ms).

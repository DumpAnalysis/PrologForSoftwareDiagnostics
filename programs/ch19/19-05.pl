% 19-05.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 19. Exceptions and Faults: 19.3 NULL Pointer (Data).
% Program block 5 of the chapter.

% access_violation(TID): the exception of TID is
% an access violation.
access_violation(TID) :-
    exception_record(TID, 0xc0000005, _).

% null_pointer_data(TID): TID read or wrote
% through a null pointer.
null_pointer_data(TID) :-
    access_violation(TID),
    exception_info(TID, access, Access),
    Access \== execute,
    exception_info(TID, target, Target),
    threshold(null_page, Limit),
    Target < Limit.

% null_pointer_data(TID, Evidence): as above, with
% the facts the recognition rests on: the record,
% its parameters, and the null page limit.
null_pointer_data(TID, Evidence) :-
    null_pointer_data(TID),
    exception_record(TID, Code, Addr),
    findall(exception_info(TID, K, V),
            exception_info(TID, K, V), Info),
    threshold(null_page, Limit),
    Facts = [exception_record(TID, Code, Addr)
             | Rest],
    append(Info, [threshold(null_page, Limit)],
           Rest),
    Evidence = evidence('NULL Pointer (Data)',
                        TID, Facts).

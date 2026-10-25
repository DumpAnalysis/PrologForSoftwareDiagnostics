% 19-17.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 19. Exceptions and Faults: 19.14 Handled Exception (User Space).
% Program block 17 of the chapter.

% handled_exception(TID, Handler): the dispatcher
% on the stack of TID has called a handler, whose
% Module-Function is Handler.
handled_exception(TID, Handler) :-
    dispatch_frame(TID, N),
    aggregate_all(max(H),
                  ( frame(TID, H, M, _, _),
                    H < N,
                    module(M, _, _),
                    \+ system_module(M)
                  ),
                  Top),
    frame(TID, Top, HM, HF, _),
    Handler = HM-HF.

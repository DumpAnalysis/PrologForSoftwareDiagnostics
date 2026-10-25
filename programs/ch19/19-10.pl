% 19-10.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 19. Exceptions and Faults: 19.8 Local Buffer Overflow (User Space).
% Program block 10 of the chapter.

% local_buffer_overflow(TID, Frames): TID has an
% exception and Frames lists the N-Addr pairs of
% its frames below the top whose return address is
% in no module and looks like text.
local_buffer_overflow(TID, Frames) :-
    exception_record(TID, _, _),
    findall(N-Addr,
            ( frame_address(TID, N, Addr),
              N >= 1,
              \+ address_module(Addr, _),
              looks_like_text(Addr)
            ),
            Frames),
    Frames \== [].

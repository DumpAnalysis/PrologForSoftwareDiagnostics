% 19-08.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 19. Exceptions and Faults: 19.6 Wild Pointer.
% Program block 8 of the chapter.

% value_bytes(Value, Bytes): Bytes are the bytes
% of the non-negative integer Value, least
% significant first, without leading zero bytes.
value_bytes(Value, Bytes) :-
    (   Value =:= 0
    ->  Bytes = []
    ;   B is Value /\ 0xff,
        Rest is Value >> 8,
        value_bytes(Rest, Bytes0),
        Bytes = [B | Bytes0]
    ).

% printable(B): byte B is a printable ASCII
% character.
printable(B) :-
    B >= 0x20,
    B =< 0x7e.

% looks_like_text(Value): Value has at least the
% threshold many bytes and all are printable.
looks_like_text(Value) :-
    value_bytes(Value, Bytes),
    threshold(text_bytes, Min),
    length(Bytes, N),
    N >= Min,
    maplist(printable, Bytes).

% wild_pointer(TID): the invalid pointer of TID
% looks like text.
wild_pointer(TID) :-
    invalid_pointer(TID),
    exception_info(TID, target, Target),
    looks_like_text(Target).

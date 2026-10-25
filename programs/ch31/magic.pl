% magic.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 31. Integration: Scripts, Embedding, and Debugger Extensions: 31.7.2 The Schema of Part II over a Snapshot.
% Program block 6 of the chapter.

% inspect_magic(S, Address, Verdict): the example
% rule of the extension's distribution, verbatim:
% a three-way verdict on eight bytes, and never a
% bare failure.
inspect_magic(S,Address,Verdict) :-
    wd:memory(S,Address,8,Result),
    ( Result = ok([80,82,79,76,79,71,68,66])
      -> Verdict=matched(prologdb,Address)
    ; Result = ok(Bytes)
      -> Verdict=mismatch(Bytes)
    ; Verdict=inconclusive(Result) ).

% What the DLL would answer three READ requests
% with: a full read, a short read at a page edge,
% and a failed one. The hook is the module's own
% extension point; the worker binds it to the
% pipe.
:- multifile wd:memory_provider/4.
wd:memory_provider(1, 0x7ff6_1d13_a000, 8,
    ok([80,82,79,76,79,71,68,66])).
wd:memory_provider(1, 0x7ff6_1d13_aff8, 8,
    partial([80,82,79,76], 8,
            "HRESULT 0x0; requested 8, read 4")).
wd:memory_provider(1, 0x10, 8,
    unavailable("HRESULT 0x8000FFFF")).

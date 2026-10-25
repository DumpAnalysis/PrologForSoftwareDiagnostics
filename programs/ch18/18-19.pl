% 18-19.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 18. Stack Traces and Threads: 18.19 Coincidental Symbolic Information.
% Program block 19 of the chapter.

% raw_stack(TID, Addr, Value): the word at stack
% address Addr of thread TID holds Value. An
% extension of the schema.
raw_stack(108, 0xf1_2bff_e8a0, 0x18).
raw_stack(108, 0xf1_2bff_e8a8, 0x7ffb_b0b0_8f5e).
raw_stack(108, 0xf1_2bff_e8b0, 0xf1_2bff_e900).
raw_stack(108, 0xf1_2bff_e8b8, 0x7ffb_b2a0_0000).
raw_stack(108, 0xf1_2bff_e8c0, 0x7ff6_1d10_3a2c).
raw_stack(108, 0xf1_2bff_e8c8, 0x7ffb_8d10_12c4).
raw_stack(108, 0xf1_2bff_e8d0, 0x1f4).
raw_stack(108, 0xf1_2bff_e8d8, 0x7ffb_6f30_1040).

% address_module(Addr, Module): Addr lies in the
% address range of Module.
address_module(Addr, Module) :-
    module(Module, Base, Size),
    Base =< Addr,
    Addr < Base + Size.

% symbol_like(Value, Module, Offset): Value lies
% in Module at Offset; dps would show a symbol.
symbol_like(Value, Module, Offset) :-
    address_module(Value, Module),
    module(Module, Base, _),
    Offset is Value - Base.

% coincidental_symbolic_information(TID, Addr, M):
% the raw stack word at Addr of TID lies in module
% M at a page-aligned offset.
coincidental_symbolic_information(TID, Addr, M) :-
    raw_stack(TID, Addr, Value),
    symbol_like(Value, M, Offset),
    Offset /\ 0xfff =:= 0.

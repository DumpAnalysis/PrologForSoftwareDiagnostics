% 21-12.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 21. Memory, Heaps, Handles, and Leaks: 21.11 Value References.
% Program block 12 of the chapter.

% raw_stack(TID, Addr, Word): the 8-byte Word at
% stack address Addr of thread TID. An extension
% of the schema.
raw_stack(109, 0xe4_1a7f_f6a0, 0x210_a204_1040).
raw_stack(109, 0xe4_1a7f_f6a8, 0x7ffb_8d10_3e8c).
raw_stack(109, 0xe4_1a7f_f6b0, 0x0).
raw_stack(109, 0xe4_1a7f_f6b8, 0x18).
raw_stack(109, 0xe4_1a7f_f6c0, 0x7ff6_1d13_a0c0).
raw_stack(109, 0xe4_1a7f_f6c8, 0x7ffb_b2a1_2f10).
raw_stack(109, 0xe4_1a7f_f6d0,
          0xcdcd_cdcd_cdcd_cdcd).

% reference(Value, Where): Value occurs at Where.
reference(Value, stack(TID, Addr)) :-
    raw_stack(TID, Addr, Value).
reference(Value, critical_section) :-
    critical_section(Value, _, _, _).
reference(Value, exception_target(TID)) :-
    exception_info(TID, target, Value).
reference(Value, heap_block) :-
    distinct(Value, heap_op(_, _, Value, _)).

% value_references(Value, Refs): Refs are the
% places Value occurs, at least two of them.
value_references(Value, Refs) :-
    distinct(Value, reference(Value, _)),
    findall(Where, reference(Value, Where), Refs),
    Refs = [_, _ | _].

% print_references: every value with at least two
% references, one line per reference.
print_references :-
    forall(value_references(V, Refs),
           ( format("~16r~n", [V]),
             forall(member(R, Refs),
                    format("  ~w~n", [R]))
           )).

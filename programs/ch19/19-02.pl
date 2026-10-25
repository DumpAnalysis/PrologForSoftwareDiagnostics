% 19-02.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 19. Exceptions and Faults.
% Program block 2 of the chapter.

:- use_module(library(pprint)).

% threshold(Name, Value): the thresholds.
% frame_run is Chapter 18's run length for a Frame
% Regularity; overflow_run is the longer run that
% makes a deep stack a suspected overflow.
threshold(null_page, 0x1_0000).
threshold(stack_depth, 12).
threshold(frame_run, 4).
threshold(overflow_run, 6).
threshold(text_bytes, 4).

% status_name(Code, Name): the name of a status
% code that marks a kind of exception.
status_name(0xc0000005, access_violation).
status_name(0xc0000094, divide_by_zero).
status_name(0xc00000fd, stack_overflow).
status_name(0xe06d7363, cpp_exception).
status_name(0xe0434352, clr_exception).
status_name(0x80000003, breakpoint).

% system_module(M): M belongs to the operating
% system or a runtime, not to the application.
system_module(ntdll).
system_module(kernelbase).
system_module(kernel32).
system_module(ucrtbase).
system_module(msvcp140).
system_module(vcruntime140).
system_module(coreclr).

% pattern(Name, Artifact, Chapter): the patterns
% this chapter recognizes with a predicate.
pattern('Exception Stack Trace', memory_dump, 19).
pattern('Fault Context', memory_dump, 19).
pattern('NULL Pointer (Data)', memory_dump, 19).
pattern('NULL Pointer (Code)', memory_dump, 19).
pattern('Invalid Pointer (General)',
    memory_dump, 19).
pattern('Wild Pointer', memory_dump, 19).
pattern('Wild Code', memory_dump, 19).
pattern('Local Buffer Overflow (User Space)',
        memory_dump, 19).
pattern('Stack Overflow (User Mode)',
    memory_dump, 19).
pattern('Divide by Zero (User Mode)',
    memory_dump, 19).
pattern('Nested Exceptions (User Space)',
        memory_dump, 19).
pattern('Multiple Exceptions (User Space)',
        memory_dump, 19).
pattern('Hidden Exception (User Space)',
        memory_dump, 19).
pattern('Handled Exception (User Space)',
        memory_dump, 19).
pattern('C++ Exception', memory_dump, 19).
pattern('Managed Code Exception',
    memory_dump, 19).
pattern('Stored Exception', memory_dump, 19).
pattern('Exception Module', memory_dump, 19).
pattern('Problem Module', memory_dump, 19).
pattern('Crash Signature', memory_dump, 19).

% show(Term): print Term over several lines that
% fit the width of this book's pages.
show(Term) :-
    print_term(Term, [right_margin(46),
                      tab_width(0)]),
    nl.

% address_module(Addr, Module): Addr lies in the
% address range of Module.
address_module(Addr, Module) :-
    module(Module, Base, Size),
    Base =< Addr,
    Addr < Base + Size.

% stack_trace(TID, Frames): the frame/5 terms of
% TID, top frame first.
stack_trace(TID, Frames) :-
    findall(frame(TID, N, M, F, O),
            frame(TID, N, M, F, O), Frames0),
    sort(2, @=<, Frames0, Frames).

% frame_symbol(Frame, Symbol): the debugger's text
% for Frame; the address alone for a frame in no
% module.
frame_symbol(frame(TID, N, M, F, O), Symbol) :-
    (   M == none
    ->  (   frame_address(TID, N, Addr)
        ->  format(atom(Symbol), "0x~16r", [Addr])
        ;   Symbol = '<no module>'
        )
    ;   F == 'Unknown'
    ->  format(atom(Symbol), "~a+0x~16r", [M, O])
    ;   format(atom(Symbol), "~a!~a+0x~16r",
               [M, F, O])
    ).

% print_stack_trace(TID): one line per frame.
print_stack_trace(TID) :-
    stack_trace(TID, Frames),
    forall(member(Frame, Frames),
           ( Frame = frame(_, N, _, _, _),
             frame_symbol(Frame, Symbol),
             format("~`0t~d~2| ~a~n", [N, Symbol])
           )).

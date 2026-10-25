% 28-19.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 28. Sequences, Motifs, and Correlation: 28.17 Small DA+TA.
% Program block 19 of the chapter.

% trace_exception(-TID, -Code): a thread
% reported an unhandled exception with Code.
trace_exception(TID, Code) :-
    msg(_, _, _, TID, _, Text),
    split_string(Text, " ,", " ,", Parts),
    member(P, Parts),
    sub_string(P, 0, 2, _, "0x"),
    number_string(Code, P),
    Code >= 0xc000_0000.

% exception_corroborated(-TID, -Code, -Address):
% the trace's exception on TID matches the
% dump's exception_record/3, giving the Address.
exception_corroborated(TID, Code, Address) :-
    trace_exception(TID, Code),
    exception_record(TID, Code, Address).

% 27-27.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.25 Translated Message.
% Program block 27 of the chapter.

:- multifile msg/7.

msg(de, 1, 0.000, 4120, 100, appserver,
    "Dienst startet, Version 3.2.1.0").
msg(de, 2, 1.002, 4120, 100, appserver,
    "Anforderung 1 empfangen: GET /report/17").
msg(de, 3, 1.311, 4120, 101, appserver,
    "Anforderung 1 abgeschlossen: 200, 309 ms").
msg(de, 4, 14.002, 4120, 109, dbclient,
    "Fehler: Kopie fehlgeschlagen, Code=0x3e6").
msg(de, 5, 14.010, 4120, 100, appserver,
    "Dienst wird beendet").

% translation(?Foreign, ?English): the invariant
% Foreign is the localized form of English.
translation(
    "Dienst startet, Version #",
    "Service starting, version #").
translation(
    "Anforderung # empfangen: GET /report/#",
    "Request # received: GET /report/#").
translation(
    "Anforderung # abgeschlossen: #, # ms",
    "Request # completed: #, # ms").
translation(
    "Fehler: Kopie fehlgeschlagen, Code=#",
    "Error: buffer copy failed, code=#").
translation(
    "Dienst wird beendet",
    "Service stopping").

% digit_tokens(+Text, -Tokens): the runs of Text
% that invariant/2 blanks, as strings, in order.
digit_tokens(Text, Tokens) :-
    string_codes(Text, Codes),
    digit_runs(Codes, Tokens).

digit_runs([], []).
digit_runs([C|Cs], Tokens) :-
    (   code_type(C, digit)
    ->  take_run([C|Cs], Run, Rest),
        string_codes(Token, Run),
        Tokens = [Token|Tokens1],
        digit_runs(Rest, Tokens1)
    ;   digit_runs(Cs, Tokens)
    ).

take_run(Cs, Run, Rest) :-
    (   Cs = [C|Cs1],
        (   code_type(C, alnum)
        ;   C == 0'.
        )
    ->  Run = [C|Run1],
        take_run(Cs1, Run1, Rest)
    ;   Run = [],
        Rest = Cs
    ).

% fill(+Inv, +Tokens, -Text): Text is Inv with
% each # replaced by the next of Tokens.
fill(Inv, Tokens, Text) :-
    string_codes(Inv, Codes),
    fill_codes(Codes, Tokens, Out),
    string_codes(Text, Out).

fill_codes([], [], []).
fill_codes([C|Cs], Tokens, Out) :-
    (   C == 0'#
    ->  Tokens = [Token|Tokens1],
        string_codes(Token, TCodes),
        append(TCodes, Out1, Out),
        fill_codes(Cs, Tokens1, Out1)
    ;   Out = [C|Out1],
        fill_codes(Cs, Tokens, Out1)
    ).

% translated_message(+Trace, ?N, -English):
% message N of Trace, translated back by its
% invariant.
translated_message(T, N, English) :-
    trace_text(T, N, _, _, Text),
    invariant(Text, Foreign),
    translation(Foreign, EnglishInv),
    digit_tokens(Text, Tokens),
    fill(EnglishInv, Tokens, English).

% 28-11.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 28. Sequences, Motifs, and Correlation: 28.10 Data Reversal.
% Program block 11 of the chapter.

:- multifile msg/7.

% a buffer-reordered excerpt: the reply was
% flushed before the send that caused it.
msg(rev, 1, 5.000, 4120, 120, dbclient,
    "Reply received: session=90, bytes=256").
msg(rev, 2, 5.001, 4120, 120, dbclient,
    "Send start: session=90, bytes=1024").

% session_token(+Text, -Tok): Text's session=
% token.
session_token(Text, Tok) :-
    split_string(Text, " ,", " ,", Words),
    member(Tok, Words),
    sub_string(Tok, 0, 8, _, "session=").

% data_reversal(+Trace, -Key, -Reply, -Send): in
% Trace a reply for Key on a thread precedes the
% send for Key on the same thread.
data_reversal(Trace, Key, Reply, Send) :-
    msg(Trace, Reply, _, _, TID, _, RText),
    sub_string(RText, 0, _, _, "Reply received"),
    session_token(RText, Key),
    msg(Trace, Send, _, _, TID, _, SText),
    sub_string(SText, 0, _, _, "Send start"),
    session_token(SText, Key),
    Reply < Send.

% 27-15.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.14 Indirect Message.
% Program block 15 of the chapter.

% indirect_message(?N, -About): message N was
% written by one thread about the thread About.
indirect_message(N, About) :-
    msg(N, _, _, TID, _, _),
    message_key(N, Word-Number),
    memberchk(Word, ["worker", "thread"]),
    number_string(About, Number),
    About =\= TID.

% 27-16.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 27. Messages: 27.15 Identification Messages.
% Program block 16 of the chapter.

% identity_word(?Word): Word introduces
% identifying information in a message.
identity_word("version").
identity_word("configuration").
identity_word("Connecting to").
identity_word("capacity=").
identity_word("threads=").

% identification_messages(-Ns): the messages
% that contain an identity_word/1.
identification_messages(Ns) :-
    findall(N,
            ( text_of(N, Text),
              once(( identity_word(W),
                     sub_string(Text, _, _, _, W)
                  ))
            ),
            Ns).

% 24-04.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 24. Trace Structure: 24.3 Message Set.
% Program block 4 of the chapter.

% message_set(Template, Set): Set is the set of
% numbers of the messages unifying with Template,
% a msg/6 term with variables for the free fields.
message_set(Template, Set) :-
    Template = msg(N, _, _, _, _, _),
    findall(N, Template, Ns),
    sort(Ns, Set).

% text_set(Sub, Set): Set is the set of messages
% whose text contains the string Sub.
text_set(Sub, Set) :-
    findall(N,
            ( msg(N, _, _, _, _, Text),
              sub_string(Text, _, _, _, Sub) ),
            Ns),
    sort(Ns, Set).

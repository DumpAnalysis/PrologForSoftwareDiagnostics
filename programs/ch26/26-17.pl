% 26-17.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 26. Activities and Threads of Activity: 26.15 Error Thread.
% Program block 17 of the chapter.

% error_word(Word): a word marking an error.
error_word("Error").
error_word("exception").
error_word("failed").

% error_message(N): message N contains an error
% word.
error_message(N) :-
    msg(N, _, _, _, _, Text),
    once(( error_word(Word),
           sub_string(Text, _, _, _, Word) )).

% error_thread(TID, Errors): Errors is the
% non-empty set of error messages of thread TID.
error_thread(TID, Errors) :-
    thread_of_activity(TID, Set),
    include(error_message, Set, Errors),
    Errors \== [].

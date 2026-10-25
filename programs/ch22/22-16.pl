% 22-16.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 22. Modules, Versions, and Environment: 22.15 Module Hint.
% Program block 16 of the chapter.

% hint_word(Word, Hint): a word in a module name
% and what it suggests.
hint_word(hook, hooking).
hint_word(inject, injection).
hint_word(guard, protection).
hint_word(shim, compatibility).
hint_word(cache, caching).

% module_hint(Module, Hint): the name of Module
% contains a hint word.
module_hint(Module, Hint) :-
    module(Module, _, _),
    hint_word(Word, Hint),
    sub_atom(Module, _, _, _, Word).

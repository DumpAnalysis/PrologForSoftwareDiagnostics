% 05-07.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 5. Lists and Recursion: 5.5 Difference Lists.
% Program block 7 of the chapter.

% dl_append(Xs, Ys, Zs): the difference list Zs is
% Xs followed by Ys.
dl_append(Front-Mid, Mid-Back, Front-Back).

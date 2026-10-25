% 12-06.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 12. Definite Clause Grammars: 12.5 A Frame Line.
% Program block 6 of the chapter.

% k_line(N, Line): the Nth line of an abridged k
% output, as a string.
k_line(0,
       "00 00000000`0014f5a8 00007ffb`b0b2a0b0 \c
        kernelbase!SleepEx+0x9e").
k_line(1,
       "01 00000000`0014f5b0 00007ff6`1d10a3a0 \c
        appserver!MainLoop+0x1b2").
k_line(2,
       "02 00000000`0014f620 00007ffb`7a002a10 \c
        cachelib+0x2a10").

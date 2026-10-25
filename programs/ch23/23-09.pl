% 23-09.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 23. Dump Quality, Composition, and Reports: 23.8 Deadlock (Critical Sections), Blocked Thread (Software), and Wait Chain (Critical Sections).
% Program block 9 of the chapter.

% implies(Pattern, Pattern2): every instance of
% Pattern contains instances of Pattern2.
implies('Deadlock (Critical Sections)',
        'Blocked Thread (Software)').
implies('Blocked Thread (Software)',
        'Wait Chain (Critical Sections)').

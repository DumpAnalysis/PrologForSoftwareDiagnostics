% 15-11.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 15. Memory Dumps as Knowledge Bases: 15.5 Unknowns and Provenance.
% Program block 11 of the chapter.

:- dynamic dump_info/2, ran/2, covering/2.

% last_status(TID, Status): the nonzero
% LastStatusValue that !teb prints for thread TID,
% from the same output as last_error/2. An
% extension of the schema, declared dynamic: the
% six inspected threads had none, so the relation
% is defined and has no facts.
:- dynamic last_status/2.

% dump_info(Key, Value): how the dump was written,
% as the analyst recorded it. An extension of the
% schema; dump1.pl does not contain it.
dump_info(file, 'dump1.dmp').
dump_info(writer, '.dump /ma').
dump_info(memory, full).
dump_info(stacks, unfiltered).
dump_info(stream, thread_list).
dump_info(stream, module_list).
dump_info(stream, exception).
dump_info(stream, thread_info).
dump_info(stream, handle_data).
dump_info(stream, unloaded_modules).

% ran(Command, Outcome): the parser found the
% output of Command in the log; Outcome is ok when
% it parsed, or failed(LineNo) when the debugger
% printed an error in its place at that line.
ran('!analyze -v', ok).
ran(lm, ok).
ran(lmv, ok).
ran('~*kn', ok).
ran('!runaway 7', ok).
ran('.exr -1', ok).
ran('!locks', ok).
ran('!cs', ok).
ran('!handle 0 0', ok).
ran('!heap -s', ok).
ran('!teb', ok).

% covering(Command, TID): the parser found the
% output of the per-thread Command for thread TID.
covering('~*kn', 100).
covering('~*kn', 101).
covering('~*kn', 102).
covering('~*kn', 103).
covering('~*kn', 104).
covering('~*kn', 105).
covering('~*kn', 106).
covering('~*kn', 107).
covering('~*kn', 108).
covering('~*kn', 109).
covering('!teb', 100).
covering('!teb', 101).
covering('!teb', 102).
covering('!teb', 103).
covering('!teb', 104).
covering('!teb', 109).

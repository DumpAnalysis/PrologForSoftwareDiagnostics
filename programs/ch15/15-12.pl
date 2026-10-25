% 15-12.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 15. Memory Dumps as Knowledge Bases: 15.5 Unknowns and Provenance.
% Program block 12 of the chapter.

% need(Need): the vocabulary of capture needs.
need(stream(_)).
need(memory(_)).
need(stacks(_)).
need(relation(_)).
need(every_thread(_)).

% capture_policy(Relation, Needs): the facts of
% Relation are complete when the command of
% source/3 ran and succeeded and the capture meets
% every need in Needs. Every relation of the
% schema declares one; an empty list is a policy.
capture_policy(process/2, []).
capture_policy(module/3, [stream(module_list)]).
capture_policy(module_info/3,
               [stream(module_list),
                memory(full)]).
capture_policy(thread/2, [stream(thread_list)]).
capture_policy(thread_time/3,
               [stream(thread_list),
                stream(thread_info)]).
capture_policy(thread_state/2,
               [relation(thread/2),
                relation(exception_record/3),
                relation(frame/5)]).
capture_policy(frame/5,
               [stream(thread_list),
                every_thread('~*kn')]).
capture_policy(exception_record/3, []).
capture_policy(exception_info/3, []).
capture_policy(critical_section/4,
               [memory(full)]).
capture_policy(waits_for/3,
               [memory(full), stacks(unfiltered),
                relation(frame/5)]).
capture_policy(handle_count/3,
               [stream(handle_data)]).
capture_policy(heap/4, [memory(full)]).
capture_policy(last_error/2,
               [stream(thread_list),
                every_thread('!teb')]).
capture_policy(last_status/2,
               [stream(thread_list),
                every_thread('!teb')]).
capture_policy(hooked/3, []).

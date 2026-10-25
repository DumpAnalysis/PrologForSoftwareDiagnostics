% 06-01.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 6. Arithmetic: 6.5 Generating Integers.
% Program block 1 of the chapter.

% sum_acc(Ns, Acc, Sum): Sum is Acc plus the sum
% of the numbers in Ns.
sum_acc([], Sum, Sum).
sum_acc([N | Ns], Acc0, Sum) :-
    Acc is Acc0 + N,
    sum_acc(Ns, Acc, Sum).

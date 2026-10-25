% 12-01.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 12. Definite Clause Grammars: 12.1 Grammar Rules.
% Program block 1 of the chapter.

:- use_module(library(dcg/basics)).
:- use_module(library(dcg/high_order)).
:- use_module(library(pure_input)).

% method(M): the name of an HTTP method.
method(get) --> "GET".
method(post) --> "POST".

% health_check(M): a request line for the health
% path, with method M.
health_check(M) --> method(M), " /health".

% boundary.pl
% From "Prolog for Pattern-Oriented Software Diagnostics",
% Chapter 23. Dump Quality, Composition, and Reports: 23.10.1 Two Boundary Cases.
% Program block 14 of the chapter; loaded fresh.

% boundary.pl -- dump1.pl extended with seven
% synthetic threads for the boundary checks of
% Section 23.10. An extension of the schema; every
% value is invented. frame/5 is dynamic, so that
% the directive at the end can add frames.
:- discontiguous thread/2, frame/5,
   exception_record/3, exception_info/3.
:- dynamic frame/5.
:- include(dump1).
:- use_module(patterns_dump).

% 130: an access violation executing at address 0
thread(130, 4120).
exception_record(130, 0xc0000005, 0x0).
exception_info(130, access, execute).
exception_info(130, target, 0x0).

% 131: one function in three separate runs of two
thread(131, 4120).
frame(131, 0, appserver, f, 0x10).
frame(131, 1, appserver, f, 0x10).
frame(131, 2, appserver, g, 0x20).
frame(131, 3, appserver, f, 0x10).
frame(131, 4, appserver, f, 0x10).
frame(131, 5, appserver, g, 0x20).
frame(131, 6, appserver, f, 0x10).
frame(131, 7, appserver, f, 0x10).

% 132-134: twelve frames with a longest run of
% four, five, and six; 135: eight frames with a
% run of six; 136: three frames and the stack
% overflow status code. The frames are built by
% the directive below, one per function listed.
thread(132, 4120).
thread(133, 4120).
thread(134, 4120).
thread(135, 4120).
thread(136, 4120).
exception_record(136, 0xc00000fd,
                 0x7ff6_1d11_0010).

:- forall(member(TID-Functions,
                 [ 132-[f,f,f,f,g,h,i,j,k,l,m,n],
                   133-[f,f,f,f,f,g,h,i,j,k,l,m],
                   134-[f,f,f,f,f,f,g,h,i,j,k,l],
                   135-[f,f,f,f,f,f,g,h],
                   136-[a,b,c] ]),
          forall(nth0(N, Functions, F),
                 assertz(frame(TID, N, appserver,
                               F, 0x10)))).

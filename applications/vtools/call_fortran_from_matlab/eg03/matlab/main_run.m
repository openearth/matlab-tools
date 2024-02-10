%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Description

%% INPUT

a=2;
b=3;
c=0;
d=0;
e=[7,8.2];
f=true;
g='a';

%% CALL

fpath_dll='c:\checkouts\oet_matlab\applications\vtools\call_fortran_from_matlab\eg03\fortran\tram2\x64\Release\tram2.dll';
[lib,war]=loadlibrary(fpath_dll,'tram2.h');
[a2,b2,c2,d2,e2,f2,g2]=calllib('tram2','tram2',a,b,c,d,e,f,g);
unloadlibrary tram2

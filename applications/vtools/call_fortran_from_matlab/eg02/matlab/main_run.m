%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18945 $
%$Date: 2023-05-15 14:17:04 +0200 (Mon, 15 May 2023) $
%$Author: chavarri $
%$Id: D3D_gdm.m 18945 2023-05-15 12:17:04Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
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

[lib,war]=loadlibrary('tram2.dll','tram2.h');
[a2,b2,c2,d2,e2,f2,g2]=calllib('tram2','tram2',a,b,c,d,e,f,g);
unloadlibrary tram2

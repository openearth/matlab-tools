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

%% PREAMBLE

% dbclear all;
clear
clc
fclose all;

%% PATHS

fpath_add_oet='c:\checkouts\oet_matlab\applications\vtools\general\addOET.m';
fdir_d3d='c:\checkouts\qp\';

% fpath_add_oet='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\openearthtools_matlab\applications\vtools\general\addOET.m';
% fdir_d3d='p:\dflowfm\projects\2020_d-morphology\modellen\checkout\qp2';

%% ADD OET
 
if isunix %we assume that if Linux we are in the p-drive. 
    fpath_add_oet=strrep(strrep(strcat('/',strrep(fpath_add_oet,'P:','p:')),':',''),'\','/');
end
run(fpath_add_oet);

%% INPUT

a=2;
b=3;
c=0;
d=0;

%%

lib=loadlibrary('tram2.dll','tram2.h');
[a2,b2,c2,d2]=calllib('tram2','tram2',a,b,c,d);
unloadlibrary tram2

% assert
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17514 $
%$Date: 2021-10-04 09:15:38 +0200 (Mon, 04 Oct 2021) $
%$Author: chavarri $
%$Id: D3D_read_map.m 17514 2021-10-04 07:15:38Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_read_map.m $
%
%get data from 1 time step in D3D, output name as in D3D

function out=D3D_nefis_info(fpath_tri)

% fpath_tri='p:\studenten-riv\03_Work\221108_Anna_vd_Hoek\01_DVR\009d_ref_sim_Erl-50cm_corr\simulation\output\100006.min\trim-br2.dat';
NFStruct=vs_use(fpath_tri,'quiet');

% ismor=D3D_is(file.map);

%HELP
% vs_let(NFStruct,'-cmdhelp') %map file
% vs_disp(NFStruct)
[FIELDNAMES,DIMS,NVAL] = qpread(NFStruct,1);
a=vs_use(fpath_his,'quiet');

out=v2struct(FIELDNAMES,DIMS,NVAL,a);

end %function
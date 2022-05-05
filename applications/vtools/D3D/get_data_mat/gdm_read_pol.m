%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18017 $
%$Date: 2022-05-03 16:23:01 +0200 (Tue, 03 May 2022) $
%$Author: chavarri $
%$Id: gdm_pol_bol_grd.m 18017 2022-05-03 14:23:01Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_pol_bol_grd.m $
%
%

function [pol,pol_name]=gdm_read_pol(fpath_pol)
pol=D3D_io_input('read',fpath_pol);
pol_name=strrep(pol.name{1,1},' ','');
end %funtion
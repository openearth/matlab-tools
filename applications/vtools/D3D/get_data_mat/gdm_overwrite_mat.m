%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17958 $
%$Date: 2022-04-20 09:27:05 +0200 (Wed, 20 Apr 2022) $
%$Author: chavarri $
%$Id: create_mat_map_sal_mass_01.m 17958 2022-04-20 07:27:05Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_sal_mass_01.m $
%
%

function [ret,flg_loc]=gdm_overwrite_mat(fid_log,flg_loc,fpath_mat)

%% PARSE

if isfield(flg_loc,'overwrite')==0
    flg_loc.overwrite=0;
end

%% CALC

ret=0;

if exist(fpath_mat,'file')==2
    messageOut(fid_log,'Mat-file already exist.')
    if flg_loc.overwrite==0
        messageOut(fid_log,'Not overwriting mat-file.')
        ret=1;
        return
    end
    messageOut(fid_log,'Overwriting mat-file.')
else
    messageOut(fid_log,'Mat-file does not exist. Reading.')
end

end %function
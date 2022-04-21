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

function ret=gdm_do_mat(fid_log,flg_loc,tag)

%% PARSE

if isfield(flg_loc,'do')==0
    flg_loc.do=1;
end

%% CALC

ret=0;

if ~flg_loc.do
    messageOut(fid_log,sprintf('Not doing ''%s''',tag));
    ret=1;
end
messageOut(fid_log,sprintf('Start ''%s''',tag));

end %function
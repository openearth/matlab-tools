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

function kt_v=gdm_kt_v(flg,nt)

%% PARSE

if isfield(flg,'order_anl')==0
    flg.order_anl=1;
end

%% CALC

switch flg.order_anl
    case 1
        kt_v=1:1:nt;
    case 2
        rng('shuffle')
        kt_v=randperm(nt);
    otherwise
        error('option does not exist')
end

end %function

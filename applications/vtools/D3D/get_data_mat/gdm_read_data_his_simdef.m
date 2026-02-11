%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%

function data=gdm_read_data_his_simdef(fdir_mat,simdef,var_id,flags)

%% PARSE

%% CALC

fpath_his=simdef.file.his;

switch var_id
    case 'vpara'
        data=gdm_read_data_his_vpara(fdir_mat,fpath_his,flags);
        data.val=data.v_para;
    case 'vperp'
        data=gdm_read_data_his_vpara(fdir_mat,fpath_his,flags);
        data.val=data.v_perp;
    otherwise
        data=gdm_read_data_his(fdir_mat,fpath_his,var_id,flags);
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 20066 $
%$Date: 2025-02-23 15:47:47 +0100 (Sun, 23 Feb 2025) $
%$Author: chavarri $
%$Id: gdm_layer.m 20066 2025-02-23 14:47:47Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_layer.m $
%
%

function [var_idx,sum_var_idx]=gdm_var_idx(simdef,flg_loc,var_idx,sum_var_idx,var_str_original)

%% PARSE

flg_loc=isfield_default(flg_loc,'sand_limit',0.002);

%% CALC

switch var_str_original
    case 'Fs' %fraction of sand
        dk=D3D_read_sed(simdef.file.sed);
        var_idx=find(dk<flg_loc.sand_limit);
        if isempty(var_idx)
            error('All fractions are above the sand limit of 0.002 m.')
        end
        sum_var_idx=1;
    case 'Fak'
        if isempty(var_idx)
            dk=D3D_read_sed(simdef.file.sed);
            var_idx=1:1:numel(dk);
        end
end

end %function
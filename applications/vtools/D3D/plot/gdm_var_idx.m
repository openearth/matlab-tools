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

function [var_idx,sum_var_idx]=gdm_var_idx(simdef,flg_loc,var_idx,sum_var_idx,var_str_original)

%% PARSE

flg_loc=isfield_default(flg_loc,'sand_limit',0.002);

%% CALC

switch var_str_original
    case 'Fs' %fraction of sand
        dk=gdm_read_dk(simdef);
        var_idx=find(dk<flg_loc.sand_limit);
        if isempty(var_idx)
            error('All fractions are above the sand limit of 0.002 m.')
        end
        sum_var_idx=1;
    case 'Fak'
        if isempty(var_idx)
            dk=gdm_read_dk(simdef);
            var_idx=1:1:numel(dk);
        end
end

end %function
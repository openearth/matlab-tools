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
%Add `stot_sum` to variables to plot if there is `stot` and `var_idx` is empty.

function flg_loc=gdm_parse_stot(flg_loc,simdef)

if ismember('stot',flg_loc.var)
    nvar=numel(flg_loc.var);
    dk=D3D_read_sed(simdef.file.sed);
    nf=numel(dk);
    for kvar=1:nvar
        if strcmp('stot',flg_loc.var{kvar})
            if isempty(flg_loc.var_idx{kvar})
                flg_loc.var_idx{kvar}=1:1:nf;
            end
        end
    end
    flg_loc.var=cat(2,flg_loc.var,{'stot_sum'});
    flg_loc=gdm_add_flags_plot(flg_loc);
    flg_loc.var_idx{end}=1:1:nf;
end %function 
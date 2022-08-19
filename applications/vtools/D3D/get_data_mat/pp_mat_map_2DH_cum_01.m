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

function pp_mat_map_2DH_cum_01(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

%% PATHS

% fdir_mat=simdef.file.mat.dir;
% fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
% fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');

%% DIMENSIONS

nvar=numel(flg_loc.var);

%% LOOP VAR
for kvar=1:nvar
    varname=flg_loc.var{kvar};
    var_str=D3D_var_num2str_structure(varname,simdef);
    
    switch var_str
        case 'clm2'
            create_mat_map_sal_mass_cum_01(fid_log,flg_loc,simdef,var_str)
        otherwise %no cummulative value over surface
    end
            
end %kvar

%% SAVE

% %only dummy for preventing passing through the function if not overwriting
% data=NaN;
% save(fpath_mat,'data')

end %function

%% 
%% FUNCTION
%%

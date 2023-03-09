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

function plot_map_2DH_Fourier2D(fid_log,flg_loc,simdef)

tag=flg_loc.tag;

%% DO

ret=gdm_do_mat(fid_log,flg_loc,tag); if ret; return; end

%% PARSE

if isfield(flg_loc,'do_Fourier2D')==0
    flg_loc.do_Fourier2D=zeros(size(flg_loc.var));
end

% if isfield(flg_loc,'var_idx')==0
%     flg_loc.var_idx=cell(1,numel(flg_loc.var));
% end
% var_idx=flg_loc.var_idx;

%% PATHS

% fdir_mat=simdef.file.mat.dir;
% fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
% fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');

%% DIMENSIONS

nvar=numel(flg_loc.var);

%% LOOP VAR
for kvar=1:nvar
    if ~flg_loc.do_Fourier2D(kvar)
        continue
    end
    
    varname=flg_loc.var{kvar};
    var_str=D3D_var_num2str_structure(varname,simdef);
    
    for kfig=1:4
        flg_loc_2=flg_loc;
        flg_loc_2.tag=strcat(flg_loc.tag,sprintf('_Fourier2D_%d',kfig));
        flg_loc_2.tag_tim=flg_loc.tag;

        plot_tim_y(fid_log,flg_loc_2,simdef,var_str)            
    end
end %kvar


end %function

%% 
%% FUNCTION
%%

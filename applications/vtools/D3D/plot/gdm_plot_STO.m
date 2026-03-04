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

function gdm_plot_STO(fid_log,flg_loc,simdef)

[tag,tag_fig,tag_serie]=gdm_tag_fig(flg_loc);

%% DO

tag_do='do_p';
ret=gdm_do_mat(fid_log,flg_loc,tag,tag_do); if ret; return; end

%% PARSE

% flg_loc=gdm_parse_sto(fid_log,flg_loc,simdef);

%% PATHS

% fdir_mat=simdef(1).file.mat.dir;
% fpath_mat=fullfile(fdir_mat,sprintf('%s.mat',tag));
% fpath_mat_time=strrep(fpath_mat,'.mat','_tim.mat');
% fdir_fig=fullfile(simdef(1).file.fig.dir,tag_fig,tag_serie);
% mkdir_check(fdir_fig);

%% SUMMERBED PLOT

if flg_loc.do_sb
    var_2_v=gdm_STO_variables_label(fid_log,flg_loc);
    for ksim=1:numel(simdef)
        gdm_STO_plot_SMB(fid_log,flg_loc,simdef(ksim),var_2_v)
    end
end

end %function
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

function [flg_loc,simdef]=gdm_parse_map_2DH(fid_log,flg_loc,simdef)

flg_loc=gdm_default_flags(flg_loc);

flg_loc=isfield_default(flg_loc,'overwrite',0);

flg_loc=isfield_default(flg_loc,'do_p_single',1);
flg_loc=isfield_default(flg_loc,'do_diff_t',0);
flg_loc=isfield_default(flg_loc,'do_diff_s',0);
flg_loc=isfield_default(flg_loc,'do_diff_s_t',0);
flg_loc=isfield_default(flg_loc,'do_diff_s_perc',0);
flg_loc=isfield_default(flg_loc,'do_diff_t_first_time',1);
flg_loc=isfield_default(flg_loc,'do_diff_s_ref_sim',1);
flg_loc=isfield_default(flg_loc,'do_2D',1);
flg_loc=isfield_default(flg_loc,'do_3D',0);
flg_loc=isfield_default(flg_loc,'plot_tiles',0);
flg_loc=isfield_default(flg_loc,'fpath_tiles',fullfile(pwd,'tiles.mat'));
flg_loc=isfield_default(flg_loc,'do_movie',0);
flg_loc=isfield_default(flg_loc,'do_fxw',0);
flg_loc=isfield_default(flg_loc,'tim_type',1);
flg_loc=isfield_default(flg_loc,'var_idx',cell(1,numel(flg_loc.var)));
flg_loc=isfield_default(flg_loc,'sim_ref',1);
flg_loc=isfield_default(flg_loc,'xlims',[NaN,NaN]);
flg_loc=isfield_default(flg_loc,'ylims',[NaN,NaN]);
flg_loc=isfield_default(flg_loc,'measurements','');

flg_loc=isfield_default(flg_loc,'write_shp',0);
if flg_loc.write_shp==1
    messageOut(fid_log,'You want to write shp files. Be aware it is quite expensive.')
end

if flg_loc.plot_tiles && ~isfield(flg_loc,'epsg_in')
    flg_loc.epsg_in=D3D_epsg(simdef(1).file.grd);
    if isempty(flg_loc.epsg_in)
        flg_loc.epsg_in=28992; %assume amersfort
    end
end
flg_loc=isfield_default(flg_loc,'ylims',[NaN,NaN]);

%% clims

flg_loc=isfield_default(flg_loc,'clims_type',1);

plottypes={'','diff_t','diff_s','diff_s_t','diff_s_perc'};
props={'clims','cmap','filter_lims'};

nplottypes=numel(plottypes); %number of plot types
nprops=numel(props); %number of properties to adjust

%save
flg_loc.plottypes=plottypes; 
flg_loc.props=props; 

% %possible way to move forward in object oriented! :)
% F=@(clims_str_var,clims_str,flg_loc)gdm_parse_ylims(fid_log,flg_loc,clims_str_var);
% % %make function of this
% str_plottypes={'','diff_t','diff_s','diff_s_t','diff_s_perc'};
% nplottypes=numel(str_plottypes); %number of plot types
% for kpt=1:nplottypes
%     [clims_str_var,clims_str]=gmd_str_plot_type_to_str_clims(str_plottypes,kpt,'clims');
%     flg_loc=F(clims_str_var,clims_str,flg_loc); 
% end

for kpt=1:nplottypes
    for kprop=1:nprops
        clims_str_var=gmd_str_plot_type_to_str_clims(plottypes,kpt,props{kprop});
        flg_loc=gdm_parse_ylims(fid_log,flg_loc,clims_str_var); 
    end
end

%%

flg_loc=gdm_parse_plot_along_rkm(flg_loc);

%% dimensions

nvar=numel(flg_loc.var);
clims_max=[];
for kpt=1:nplottypes
    clims_str_var=gmd_str_plot_type_to_str_clims(plottypes,kpt,'clims');
    for kvar=1:nvar
        clims_max=cat(1,clims_max,size(flg_loc.(clims_str_var){kvar},1));
    end
end

flg_loc.nclim_max=max(clims_max);
flg_loc.nsim=numel(simdef);
flg_loc.nxlim=size(flg_loc.xlims,1);
flg_loc.nvar=nvar;
flg_loc.nplottypes=nplottypes;
flg_loc.nprops=nprops;

%% 

flg_loc.do_ref=0;
if flg_loc.nsim>1 && (flg_loc.do_diff_s || flg_loc.do_diff_s_t || flg_loc.do_diff_s_perc)
    flg_loc.do_ref=1;
end

%%
 %In 1D-2D simulations, the simulations is identified as 1D because it has 1D data. We have to force to
 %plot the 2D data if we are in `map_2DH`.
 if simdef(1).D3D.is1d
     messageOut(fid_log,'This seems a 1D-2D simulation, as you want to plot 2D data but there is 1D data in the results. Plotting 2D.')
     simdef(1).D3D.is1d=false;
 end

end %function

%%
%% FUNCTIONS
%%


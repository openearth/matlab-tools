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

function flg_loc=gdm_parse_his(fid_log,flg_loc,simdef)



%% stations

%There are two inputs which are handled the same way:
%   -his-file
%   -map_2DH_his
flg_loc=isfield_default(flg_loc,'his_type',1);        
flg_loc=isfield_default(flg_loc,'results_type','his');        
if isfield(flg_loc,'obs')
    flg_loc.his_type=2;
    flg_loc.results_type='map';
end

fpath_his=simdef(1).file.his;
switch flg_loc.his_type
    case 1
        flg_loc=gdm_station_names(fid_log,flg_loc,fpath_his,'model_type',simdef(1).D3D.structure);
    case 2
        flg_loc.stations={flg_loc.obs.name};
end
flg_loc.nobs=numel(flg_loc.stations);

%% independent of size

flg_loc=isfield_default(flg_loc,'plot_type',1);        
flg_loc=isfield_default(flg_loc,'interp_measurements',0);   
flg_loc=isfield_default(flg_loc,'do_statistics',0);   
flg_loc=isfield_default(flg_loc,'do_fil',0);        
flg_loc=isfield_default(flg_loc,'fil_tim',25*3600);        
flg_loc=isfield_default(flg_loc,'do_convergence',0);        
flg_loc=isfield_default(flg_loc,'do_all_sta',0);    
flg_loc=isfield_default(flg_loc,'do_all_sim',1);    
flg_loc=isfield_default(flg_loc,'do_p_single',1);       
flg_loc=isfield_default(flg_loc,'do_sal_01',0);   
flg_loc=isfield_default(flg_loc,'measurements','');
flg_loc=isfield_default(flg_loc,'tol',1.5e-7);
flg_loc=isfield_default(flg_loc,'write_shp',0);
if flg_loc.write_shp==1
    messageOut(fid_log,'You want to write shp files. Be aware it is quite expensive.')
end

flg_loc=gdm_parse_ylims(fid_log,flg_loc,'ylims_var'); 
flg_loc=gdm_parse_ylims(fid_log,flg_loc,'ylims_diff_var');

%% special cases

if flg_loc.do_sal_01
    flg_loc.var={'sal','wl'};
    flg_loc.plot_type=2;
    flg_loc.interp_measurements=1;
    flg_loc.do_statistics=1;
    flg_loc.unit={'sal',''};
    flg_loc.do_s=0;
    flg_loc.do_all_sim=0;
%     flg_loc.do_all_sta=0; %we need only one station at each result for the statistics?
end

%% size

flg_loc.nvar=numel(flg_loc.var);

%% dependent on size

%obs
flg_loc=isfield_default(flg_loc,'elev',NaN(flg_loc.nobs,1));     

%var
flg_loc=isfield_default(flg_loc,'depth_average',zeros(flg_loc.nvar,1));        
flg_loc=isfield_default(flg_loc,'unit',cell(flg_loc.nvar,1));
flg_loc=isfield_default(flg_loc,'depth_average_limits',repmat([-inf,inf],flg_loc.nvar,1));
flg_loc=isfield_default(flg_loc,'sum_var_idx',zeros(flg_loc.nvar,1));        
flg_loc=isfield_default(flg_loc,'var_idx',cell(flg_loc.nvar,1));
flg_loc=isfield_default(flg_loc,'projection_angle',NaN(flg_loc.nvar,1));

end
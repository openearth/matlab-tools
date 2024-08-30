%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19684 $
%$Date: 2024-06-21 22:39:59 +0200 (Fri, 21 Jun 2024) $
%$Author: chavarri $
%$Id: create_mat_his_01.m 19684 2024-06-21 20:39:59Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_his_01.m $
%
%

function flg_loc=gdm_parse_his(fid_log,flg_loc,simdef)

%% size

flg_loc.nvar=numel(flg_loc.var);

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
        flg_loc.stations=gdm_station_names(fid_log,flg_loc,fpath_his,'model_type',simdef(1).D3D.structure);
    case 2
        flg_loc.stations={flg_loc.obs.name};
end
flg_loc.ns=numel(flg_loc.stations);

%% independent of size

flg_loc=isfield_default(flg_loc,'do_fil',0);        
flg_loc=isfield_default(flg_loc,'fil_tim',25*3600);        
flg_loc=isfield_default(flg_loc,'do_convergence',0);        
flg_loc=isfield_default(flg_loc,'do_all_sta',0);        
flg_loc=isfield_default(flg_loc,'measurements','');

flg_loc=gdm_parse_ylims(fid_log,flg_loc,'ylims_var'); 
flg_loc=gdm_parse_ylims(fid_log,flg_loc,'ylims_diff_var');

%% dependent on size
flg_loc=isfield_default(flg_loc,'elev',NaN(flg_loc.ns,1));        
flg_loc=isfield_default(flg_loc,'depth_average',zeros(flg_loc.nvar,1));        
flg_loc=isfield_default(flg_loc,'unit',cell(flg_loc.nvar,1));

end
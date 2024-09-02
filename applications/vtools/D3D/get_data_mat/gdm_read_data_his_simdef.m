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

function data=gdm_read_data_his_simdef(fdir_mat,simdef,var_id,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'sim_idx',[]);
addOptional(parin,'layer',[]);
addOptional(parin,'station',[]);
addOptional(parin,'elevation',NaN);
addOptional(parin,'angle',NaN);
addOptional(parin,'depth_average',false);

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
sim_idx=parin.Results.sim_idx;
layer=parin.Results.layer;
station=parin.Results.station;
elev=parin.Results.elevation;
projection_angle=parin.Results.angle;
depth_average=parin.Results.depth_average;

%% CALC

fpath_his=simdef.file.his;

switch var_id
    case 'vpara'
        data=gdm_read_data_his_vpara(fdir_mat,fpath_his,station,layer,time_dnum,simdef,sim_idx,depth_average,projection_angle,elev);
        data.val=data.v_para;
    case 'vperp'
        data=gdm_read_data_his_vpara(fdir_mat,fpath_his,station,layer,time_dnum,simdef,sim_idx,depth_average,projection_angle,elev);
        data.val=data.v_perp;
    otherwise
        data=gdm_read_data_his(fdir_mat,fpath_his,var_id,'station',station,'layer',layer,'tim',time_dnum(1),'tim2',time_dnum(end),'structure',simdef.D3D.structure,'sim_idx',sim_idx,'elevation',elev,'depth_average',depth_average);
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19229 $
%$Date: 2023-11-03 13:13:41 +0100 (Fri, 03 Nov 2023) $
%$Author: chavarri $
%$Id: gdm_read_data_his.m 19229 2023-11-03 12:13:41Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_data_his.m $
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

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
sim_idx=parin.Results.sim_idx;
layer=parin.Results.layer;
station=parin.Results.station;
elev=parin.Results.elevation;

%% CALC

fpath_his=simdef.file.his;

data=gdm_read_data_his(fdir_mat,fpath_his,var_id,'station',station,'layer',layer,'tim',time_dnum(1),'tim2',time_dnum(end),'structure',simdef.D3D.structure,'sim_idx',sim_idx);
                
%find data at a given elevation
if ~isnan(elev)
   data_z=gdm_read_data_his(fdir_mat,fpath_his,'zcoordinate_c','station',station,'layer',layer,'tim',time_dnum(1),'tim2',time_dnum(end),'structure',simdef.D3D.structure,'sim_idx',sim_idx);
   data=gdm_data_at_elevation(data,data_z,elev);
end

%depth-average data

end %function
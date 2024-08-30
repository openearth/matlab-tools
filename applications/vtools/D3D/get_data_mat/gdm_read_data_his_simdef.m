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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18036 $
%$Date: 2022-05-10 16:01:22 +0200 (Tue, 10 May 2022) $
%$Author: chavarri $
%$Id: gdm_read_data_map.m 18036 2022-05-10 14:01:22Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_data_map.m $
%
%

function data=gdm_read_data_map_char(fpath_map,varname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'layer',[]);

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
layer=parin.Results.layer;

%% CALC

if isempty(time_dnum)
    data=EHY_getMapModelData(fpath_map,'varName',varname,'mergePartitions',1,'disp',0);
else
    if isempty(layer)
        data=EHY_getMapModelData(fpath_map,'varName',varname,'t0',time_dnum,'tend',time_dnum,'mergePartitions',1,'disp',0);
    else
        data=EHY_getMapModelData(fpath_map,'varName',varname,'t0',time_dnum,'tend',time_dnum,'mergePartitions',1,'disp',0,'layer',layer);
    end
end

end %function
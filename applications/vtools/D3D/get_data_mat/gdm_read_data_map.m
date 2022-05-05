%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17976 $
%$Date: 2022-04-25 11:04:04 +0200 (Mon, 25 Apr 2022) $
%$Author: chavarri $
%$Id: create_mat_map_sal_mass_01.m 17976 2022-04-25 09:04:04Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_sal_mass_01.m $
%
%

function data=gdm_read_data_map(fdir_mat,fpath_map,varname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'layer',[]);

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
layer=parin.Results.layer;

%% CALC

fpath_sal=mat_tmp_name(fdir_mat,varname,varargin{:});

if exist(fpath_sal,'file')==2
    messageOut(NaN,sprintf('Loading mat-file with raw data: %s',fpath_sal));
    load(fpath_sal,'data')
else
    messageOut(NaN,sprintf('Reading raw data for variable: %s',varname));
    if isempty(time_dnum)
        data=EHY_getMapModelData(fpath_map,'varName',varname,'mergePartitions',1,'disp',0);
    else
        if isempty(layer)
            data=EHY_getMapModelData(fpath_map,'varName',varname,'t0',time_dnum,'tend',time_dnum,'mergePartitions',1,'disp',0);
        else
            data=EHY_getMapModelData(fpath_map,'varName',varname,'t0',time_dnum,'tend',time_dnum,'mergePartitions',1,'disp',0,'layer',layer);
        end
    end
    save_check(fpath_sal,'data');
end

end %function
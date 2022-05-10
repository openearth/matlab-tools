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
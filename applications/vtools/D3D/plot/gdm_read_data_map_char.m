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

function data=gdm_read_data_map_char(fpath_map,varname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'layer',[]);
addOptional(parin,'tol_t',5/60/24);
addOptional(parin,'bed_layers',[]);
% addOptional(parin,'pli','');

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
layer=parin.Results.layer;
tol_t=parin.Results.tol_t;
bed_layers=parin.Results.bed_layers;
% pli=parin.Results.pli;

%% CALC

%% reconstruction of unavailable variable

switch varname
    case {'mesh2d_flowelem_zw','mesh2d_flowelem_zc'}
        nci=ncinfo(fpath_map);
        if isnan(find_str_in_cell({nci.Variables.Name},{varname})) %variable you want to read is not there
            OPT.t0=time_dnum;
            OPT.tend=time_dnum;
            OPT.mergePartitions=1;
            OPT.mergePartitionNrs=[];
            [Zcen_int,Zcen_cen,~,~] = EHY_getMapModelData_construct_zcoordinates(fpath_map,'dfm',OPT);
            data.dimensions='[time,mesh2d_nFaces,mesh2d_nLayers]';
            switch varname
                case 'mesh2d_flowelem_zw'
                    data.val=Zcen_int;
                case 'mesh2d_flowelem_zc'
                    data.val=Zcen_cen;
            end
            return
        end
    otherwise
end

%% regular call

if isempty(time_dnum)
    data=EHY_getMapModelData(fpath_map,'varName',varname,'mergePartitions',1,'disp',0);
else
    data=EHY_getMapModelData(fpath_map,'varName',varname,'t0',time_dnum,'tend',time_dnum,'mergePartitions',1,'disp',0,'layer',layer,'tol_t',tol_t);%,'bed_layers',bed_layers);
    if isfield(data,'times')
        switch varname
            case {'uv'}
                fn={'times','vel_x','vel_y','vel_mag','vel_dir'};
            otherwise
                fn={'times','val'};
        end
        data=gdm_get_only_one_time(data,time_dnum,tol_t,fn);
    end
end

end %function
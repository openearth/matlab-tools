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
    case 'mesh2d_flowelem_zw'
        nci=ncinfo(fpath_map);
        if isnan(find_str_in_cell({nci.Variables.Name},{varname})) %variable you want to read is not there
            OPT.t0=time_dnum;
            OPT.tend=time_dnum;
            OPT.mergePartitions=1;
            OPT.mergePartitionNrs=[];
            [Zcen_int,~,~,~] = EHY_getMapModelData_construct_zcoordinates(fpath_map,'dfm',OPT);
            data.val=Zcen_int;
            return
        end
    otherwise
end

%% regular call

if isempty(time_dnum)
    data=EHY_getMapModelData(fpath_map,'varName',varname,'mergePartitions',1,'disp',0);
else
%     if isempty(layer)
%         if isempty(pli)
%             data=EHY_getMapModelData(fpath_map,'varName',varname,'t0',time_dnum,'tend',time_dnum,'mergePartitions',1,'disp',0,'tol_t',tol_t);
%         else
%             [data,data.grid]=EHY_getMapModelData(fpath_map,'varName',varname,'t0',time_dnum,'tend',time_dnum,'mergePartitions',1,'disp',0,'pliFile',pli);
%         end
%     else
%         if isempty(pli)
            data=EHY_getMapModelData(fpath_map,'varName',varname,'t0',time_dnum,'tend',time_dnum,'mergePartitions',1,'disp',0,'layer',layer,'tol_t',tol_t);%,'bed_layers',bed_layers);
%         else
%             data=EHY_getMapModelData(fpath_map,'varName',varname,'t0',time_dnum,'tend',time_dnum,'mergePartitions',1,'disp',0,'layer',layer,'pliFile',pli);
%         end
%     end
end

end %function
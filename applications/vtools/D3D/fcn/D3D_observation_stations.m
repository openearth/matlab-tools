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
%Read observation stations name and location

%E.G.:
%obs=D3D_observation_stations(fpath_his);
% figure
% hold on
% scatter(obs.x,obs.y)
% for ko=1:numel(obs.name)
%     text(obs.x(ko),obs.y(ko),obs.name{ko})
% end

function obs_sta=D3D_observation_stations(path_his,varargin)

simdef_def.D3D.structure=2;

parin=inputParser;

addOptional(parin,'simdef',simdef_def);
addOptional(parin,'sta','obs');

parse(parin,varargin{:});

simdef=parin.Results.simdef;
sta=parin.Results.sta;

%%

switch simdef.D3D.structure
    case 1
        %from `EHY_getmodeldata` but without loading any variable. 
        OPT.t=[];
        OPT.t0='';
        OPT.tend='';
        OPT.tint='';
        OPT.varName='';
        [dims,~,Data,~] = EHY_getDimsInfo(path_his,OPT,'d3d4',[]);
        trih = vs_use(path_his,'quiet');
        
        % station info
        locationMN = vs_get(trih,'his-const',{1},'MNSTAT','quiet')';
        Data.locationMN(Data.exist_stat,:) = locationMN(dims(stationsInd).index,:);
        locationXY = vs_get(trih,'his-const',{1},'XYSTAT','quiet')';
        Data.location(Data.exist_stat,:)   = locationXY(dims(stationsInd).index,:);

        obs_sta.name=Data.stationNames;
        obs_sta.x=Data.location(:,1);
        obs_sta.y=Data.location(:,2);
    case 3
        nci=ncinfo(path_his);
        is_sta=ismember('observation_id',{nci.Variables.Name});
        if is_sta
            obs_sta.name=cellstr(ncread(path_his,'observation_id')')';
            obs_sta.branch=ncread(path_his,'branchid')';
            obs_sta.chainage=ncread(path_his,'chainage')';
            %here we should convert to xy also by reading the grid
            obs_sta.x=[];
            obs_sta.y=[];
        else
            obs_sta.name={''};
            obs_sta.x=[];
            obs_sta.y=[];
        end
    case {2,4}
        nci=ncinfo(path_his);
        switch sta
            case 'obs'
                str_r='station_id';
            case 'cs'
                str_r='cross_section_name';
        end
        is_sta=ismember(str_r,{nci.Variables.Name});
        if is_sta
            obs_sta.name=cellstr(ncread(path_his,str_r)')';
            obs_sta.x=ncread(path_his,'station_x_coordinate')';
            obs_sta.y=ncread(path_his,'station_y_coordinate')';
        else
            obs_sta.name={''};
            obs_sta.x=[];
            obs_sta.y=[];
        end
    otherwise
        error('Implement')
end

end %function

function newName = EHY_nameOnFile(fName,varName)
%% newName = EHY_nameOnFile(fName,varName)
%
% This function returns the variable/dimension name (newName) that you would like to
% read (varName) based on the available variables names in the netCDF file (fName).
%
% Useful to deal with the changing variable names in the FM output files,
% like NetNode_x (old) which is the same as mesh2d_node_x (newer)
%
% Example1: newName = EHY_fmName('D:\runid_his.nc','sal')
%   returns newName = 'salinity';
% Example2: newName = EHY_fmName('D:\runid_map.nc','waterlevel')
%   returns newName = 'mesh2d_s1';
% Example3: newName = EHY_fmName('D:\runid_his.nc','nmesh2d_layer')
%   returns newName = laydim;
%
% E: Julien.Groenenboom@deltares.nl

%% get modelType and typeOfModelFileDetail
modelType                  = EHY_getModelType(fName);
[~, typeOfModelFileDetail] = EHY_getTypeOfModelFile(fName);

%% Change variable name (for usage in EHY_getmodeldata) for Delft3D 4, IMPLIC and SOBEK3
if strcmpi(varName,'sal')          varName = 'salinity'   ; end
if strcmpi(varName,'tem')          varName = 'temperature'; end
if strcmpi(varName,'waterlevel'  ) varName = 'wl'         ; end
if strcmpi(varName,'water level' ) varName = 'wl'         ; end
if strcmpi(varName,'waterdepth'  ) varName = 'wd'         ; end
if strcmpi(varName,'water depth' ) varName = 'wd'         ; end
if strcmpi(varName,'bedlevel'    ) varName = 'dps'        ; end
if strcmpi(varName,'bed level'   ) varName = 'dps'        ; end

%% Change the name of the requested Variable name
newName = varName;
switch typeOfModelFileDetail
    case 'his_nc'
        % Get the name of varName as specified on the history file of a simulation
        switch modelType
            case 'dfm'
                if strcmpi(varName,'wl'         ) newName = 'waterlevel'   ; end
                if strcmpi(varName,'wd'         ) newName = 'waterdepth'   ; end
                if strcmpi(varName,'dps'        ) newName = 'bedlevel'     ; end
                if strcmpi(varName,'uv'         ) newName = 'x_velocity'   ; end
                if strcmpi(varName,'Zcen'       ) newName = 'zcoordinate_c'; end
                if strcmpi(varName,'Zint'       ) newName = 'zcoordinate_w'; end
                if strcmpi(varName,'Zcen_cen'   ) newName = 'zcoordinate_c'; end
                if strcmpi(varName,'Zcen_int'   ) newName = 'zcoordinate_w'; end
        end
        
    case {'map_nc','fou_nc'}
        % Get the name of varName as specified on the map file of a simulation
        switch modelType
            case 'dfm'
                if strcmpi(varName,'wl'         ) newName = 's1'         ; end
                if strcmpi(varName,'salinity'   ) newName = 'sa1'        ; end
                if strcmpi(varName,'temperature') newName = 'tem1'       ; end
                if strcmpi(varName,'uv'         ) newName = 'ucx'        ; end
                if strcmpi(varName,'wd'         ) newName = 'waterdepth' ; end
        end
end

%% for FM output (netCDF files)
if strcmp(modelType,'dfm') && strcmp(fName(end-2:end),'.nc')
    
    %%% get ncinfo
    infonc   = ncinfo(fName);
    varNames = {infonc.Variables.Name};
    dimNames = {infonc.Dimensions.Name};
    
    %%% Change Variable or Dimension name to deal with old/new variable names like NetNode_x (older) vs. mesh2d_node_x (newer)
    %%% based on the list at the end of this script
    if ~nc_isvar(fName,newName)
        fmNames = getFmNames;
        for iN = 1:length(fmNames)
            if ismember(newName,fmNames{iN})
                newName = char(intersect(fmNames{iN},[varNames dimNames]));
            end
        end
    end
    
    %%% Change Variable or Dimension name to deal with old/new variable names like tem1 (older) vs. mesh2d_tem1 (newer)
    if ~nc_isvar(fName,newName) && ~nc_isdim(fName,newName)
        indVarNames = find(~cellfun(@isempty,strfind(lower(varNames),newName)));
        indDimNames = find(~cellfun(@isempty,strfind(lower(dimNames),newName)));
        if ~isempty(indVarNames)
            newName = infonc.Variables(indVarNames).Name;
        elseif  ~isempty(indDimNames)
            newName = infonc.Dimensions(indDimNames).Name;
        else
            newName = 'noMatchFound';
        end
    end
end
end


function fmNames = getFmNames

fmNames={};
%%% VARIABLE names used within different versions of Delft3D-Flexible Mesh
fmNames{end+1,1}={'mesh2d_node_x','NetNode_x'}; % x-coordinate of nodes
fmNames{end+1,1}={'mesh2d_node_y','NetNode_y'}; % y-coordinate of nodes
fmNames{end+1,1}={'mesh2d_node_z','NetNode_z'}; % z-coordinate of nodes

fmNames{end+1,1}={'FlowElem_xcc','mesh2d_face_x'}; % x-coordinate of faces
fmNames{end+1,1}={'FlowElem_ycc','mesh2d_face_y'}; % y-coordinate of faces

fmNames{end+1,1}={'FlowElemContour_x','mesh2d_face_x_bnd','mesh2d_agg_face_x_bnd'}; % x-coordinates of flow element contours
fmNames{end+1,1}={'FlowElemContour_y','mesh2d_face_y_bnd','mesh2d_agg_face_y_bnd'}; % y-coordinates of flow element contours

fmNames{end+1,1}={'mesh2d_flowelem_domain','FlowElemDomain'}; % flow element domain

fmNames{end+1,1}={'mesh2d_flowelem_bl','FlowElem_bl'}; % bed level

%%% DIMENSION names used within different versions of Delft3D-Flexible Mesh
fmNames{end+1,1}={'mesh2d_nNodes','nmesh2d_node','nNetNode'}; % number of nodes
fmNames{end+1,1}={'mesh2d_nFaces','nmesh2d_face','nNetElem','nFlowElem'}; % number of faces

fmNames{end+1,1}={'mesh2d_nLayers','laydim','nmesh2d_layer',}; % layer
end

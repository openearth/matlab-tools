function Data = EHY_getMapModelData_xy(inputFile,varargin)
% TODO check arbcross (too many points now)
% Function: Create data needed for plotting of cross section information
modelType = EHY_getModelType(inputFile);

%% Initialise:
OPT                 = varargin{1};

%% Read the pli file
thalweg  = readldb(OPT.pliFile);
OPT = rmfield(OPT,'pliFile');

%% Horizontal (x,y) coordinates (TODO: edge nodes for delft3d-flow, than it is no longer needed to seperate between d3d and dfm) 
DataXY      = EHY_getGridInfo(inputFile,{'XYcor', 'XYcen','edge_nodes'},'mergePartitions',OPT.mergePartitions);
if strcmp(modelType,'dfm')
    coor_edge.x = DataXY.Xcor(DataXY.edge_nodes);
    coor_edge.y = DataXY.Ycor(DataXY.edge_nodes);
    no_edges    = size(coor_edge.x,2);
end

%% get "z-data"
[DataZ.val_int,DataZ.val_cen,DataZ.wl,DataZ.bed] = EHY_getMapModelData_construct_zcoordinates(inputFile,modelType,OPT);

%% get wanted "varName"-data for all points
DataAll = EHY_getMapModelData(inputFile,OPT);

%% check
dimTextInd = strfind(DataAll.dimensions,',');
if isempty(strfind(lower(DataAll.dimensions(dimTextInd(end)+1:end-1)),'lay'))
    error('Last dimension is not the layer-dimension and that is what this script useData. Please contact Julien.Groenenboom@deltares.nl')
elseif isempty(strfind(DataAll.dimensions(2:dimTextInd(1)-1),'time'))
    error('First dimension is not the time-dimension and that is what this script useData. Please contact Julien.Groenenboom@deltares.nl')
end

%% from [m,n] to cells (like FM)
if strcmp(modelType,'d3d')
    modelSize = size(DataAll.val);
    DataAll.val   = reshape(DataAll.val   ,[modelSize(1) prod(modelSize(2:3)) modelSize(4)]);
    DataZ.val_cen = reshape(DataZ.val_cen ,[modelSize(1) prod(modelSize(2:3)) modelSize(4)  ]);  
    DataZ.val_int = reshape(DataZ.val_int ,[modelSize(1) prod(modelSize(2:3)) modelSize(4)+1]);
    DataZ.wl      = reshape(DataZ.wl      ,[modelSize(1) prod(modelSize(2:3))               ]);
    DataZ.bed     = reshape(DataZ.bed     ,[modelSize(1) prod(modelSize(2:3))               ]);  
end
no_layers = size(DataZ.val_cen,3);

%% Calculate values at pli locations
%  Start with Arccrossing
if strcmp(modelType,'d3d')
    [Data.xcor,Data.ycor] = arbcross(DataXY.Xcor,DataXY.Ycor,thalweg.x,thalweg.y);
elseif strcmp(modelType,'dfm')
%   original (did not work properly anymore): [Data.xcor,Data.ycor] = arbcross(DataXY.face_nodes,DataXY.Xcor,DataXY.Ycor,thalweg.x,thalweg.y);
    Data.xcor = [];
    Data.ycor = [];
    for i_edge = 1: no_edges
        intersection = InterX([coor_edge.x(:,i_edge),coor_edge.y(:,i_edge)]',[thalweg.x,thalweg.y]');
        if ~isempty(intersection)
            Data.xcor(end + 1) = intersection(1);
            Data.ycor(end + 1) = intersection(2);
        end
    end
end

[Data.xcor,index] = sort(Data.xcor);
Data.ycor         = Data.ycor(index);
Data.scor         = distance(Data.xcor,Data.ycor);

Data.xcen = (Data.xcor(1:end-1) + Data.xcor(2:end)) ./ 2;
Data.ycen = (Data.ycor(1:end-1) + Data.ycor(2:end)) ./ 2;
Data.scen = (Data.scor(1:end-1) + Data.scor(2:end)) ./ 2;

Data.bed  = griddata(DataXY.Xcen,DataXY.Ycen,DataZ.bed,Data.xcen,Data.ycen,'nearest');

%  Determine vertical levels at scen locations and corresponding values
Data.times = DataAll.times;
no_times   = length(Data.times);

for i_time = 1: no_times
    for i_lay = 1: no_layers
        Data.zcen (i_time,:,i_lay) = griddata(DataXY.Xcen,DataXY.Ycen,DataZ.val_cen(i_time,:,i_lay),Data.xcen,Data.ycen,'nearest');
        Data.value(i_time,:,i_lay) = griddata(DataXY.Xcen,DataXY.Ycen,DataAll.val  (i_time,:,i_lay),Data.xcen,Data.ycen,'nearest');
    end
    
    %  Determine waterlevel along a cross section
    Data.wl(i_time,:)  = griddata(DataXY.Xcen,DataXY.Ycen,DataZ.wl(i_time,:) ,Data.xcen,Data.ycen,'nearest');
end
    
%% Fill dum array for plotting with pcolor. Maybe this should not be done here, restrict this function to just getting the data
for i_pos = 1:length(Data.xcen)
    Data.xcor_dum((2*i_pos)-1)           = Data.xcor(i_pos);
    Data.xcor_dum( 2*i_pos   )           = Data.xcor(i_pos+1);
    Data.ycor_dum((2*i_pos)-1)           = Data.ycor(i_pos);
    Data.ycor_dum( 2*i_pos   )           = Data.ycor(i_pos+1);
    Data.scor_dum((2*i_pos)-1)           = Data.scor(i_pos);
    Data.scor_dum( 2*i_pos   )           = Data.scor(i_pos+1);
    
    Data.depcen_dum((2*i_pos)-1)         = Data.bed(i_pos);
    Data.depcen_dum( 2*i_pos   )         = Data.bed(i_pos);
    
    for i_time = 1: no_times
        Data.surcen_dum(i_time,(2*i_pos)-1)         = Data.wl(i_time,i_pos);
        Data.surcen_dum(i_time, 2*i_pos   )         = Data.wl(i_time,i_pos);
        
        Data.zcor_intface_dum(i_time,(2*i_pos)-1,:) = Data.zcen(i_time,i_pos,:);
        Data.zcor_intface_dum(i_time, 2*i_pos   ,:) = Data.zcen(i_time,i_pos,:);
        
        Data.value_dum(i_time,(2*i_pos)-1,:)        = Data.value(i_time,i_pos,:);
        if i_pos ~= size(Data.xcen,1)
            Data.value_dum(i_time, 2*i_pos,:)       = nan;
        end
    end
end

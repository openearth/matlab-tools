function Data_xy = EHY_getMapModelData_xy(inputFile,varargin)
%  Function: Create data needed for plotting of cross section information
%
%% Initialise:
OPT            = varargin{1};
Data.modelType = EHY_getModelType(inputFile);

%% Read the pli file
thalweg  = readldb(OPT.pliFile);
OPT = rmfield(OPT,'pliFile');

%% Horizontal (x,y) coordinates  
tmp   = EHY_getGridInfo(inputFile,{'XYcor', 'XYcen','edge_nodes'},'mergePartitions',OPT.mergePartitions);
names = fieldnames(tmp); for i_name = 1: length(names) Data.(names{i_name}) = tmp.(names{i_name}); end

%% get "z-data"
[Data.Zint,Data.Zcen,Data.wl,Data.bed] = EHY_getMapModelData_construct_zcoordinates(inputFile,Data.modelType,OPT);

%% get wanted "varName"-data for all points
tmp   = EHY_getMapModelData(inputFile,OPT);
names = fieldnames(tmp); for i_name = 1: length(names) Data.(names{i_name}) = tmp.(names{i_name}); end
Data  = EHY_2Dto1D(Data);

no_layers   = size(Data.Zcen,3);
coor_edge.x = Data.Xcor(Data.edge_nodes);
coor_edge.y = Data.Ycor(Data.edge_nodes);
no_edges    = size(coor_edge.x,2);

%% Calculate values at pli locations
Data_xy.xcor = [];
Data_xy.ycor = [];
for i_edge = 1: no_edges
    intersection = InterX([coor_edge.x(:,i_edge),coor_edge.y(:,i_edge)]',[thalweg.x,thalweg.y]');
    if ~isempty(intersection)
        Data_xy.xcor(end + 1) = intersection(1);
        Data_xy.ycor(end + 1) = intersection(2);
    end
end

[Data_xy.xcor,index] = sort(Data_xy.xcor);
Data_xy.ycor         = Data_xy.ycor(index);
Data_xy.scor         = distance(Data_xy.xcor,Data_xy.ycor);

Data_xy.xcen = (Data_xy.xcor(1:end-1) + Data_xy.xcor(2:end)) ./ 2;
Data_xy.ycen = (Data_xy.ycor(1:end-1) + Data_xy.ycor(2:end)) ./ 2;
Data_xy.scen = (Data_xy.scor(1:end-1) + Data_xy.scor(2:end)) ./ 2;

Data_xy.bed  = griddata(Data.Xcen,Data.Ycen,Data.bed,Data_xy.xcen,Data_xy.ycen,'nearest');

%%  Determine vertical levels at scen locations and corresponding values
no_times      = length(Data.times);

for i_time = 1: no_times
    for i_lay = 1: no_layers
        Data_xy.zcen (i_time,:,i_lay) = griddata(Data.Xcen,Data.Ycen,Data.Zcen (i_time,:,i_lay),Data_xy.xcen,Data_xy.ycen,'nearest');
        Data_xy.value(i_time,:,i_lay) = griddata(Data.Xcen,Data.Ycen,Data.val  (i_time,:,i_lay),Data_xy.xcen,Data_xy.ycen,'nearest');
    end
    
    %  Determine waterlevel along a cross section
    Data_xy.wl(i_time,:)  = griddata(Data.Xcen,Data.Ycen,Data.wl(i_time,:) ,Data_xy.xcen,Data_xy.ycen,'nearest');
end
    
%% Fill dum array for plotting with pcolor. Maybe this should not be done here, restrict this function to just getting the data
for i_pos = 1:length(Data_xy.xcen)
    Data_xy.xcor_dum((2*i_pos)-1)           = Data_xy.xcor(i_pos);
    Data_xy.xcor_dum( 2*i_pos   )           = Data_xy.xcor(i_pos+1);
    Data_xy.ycor_dum((2*i_pos)-1)           = Data_xy.ycor(i_pos);
    Data_xy.ycor_dum( 2*i_pos   )           = Data_xy.ycor(i_pos+1);
    Data_xy.scor_dum((2*i_pos)-1)           = Data_xy.scor(i_pos);
    Data_xy.scor_dum( 2*i_pos   )           = Data_xy.scor(i_pos+1);
    
    Data_xy.depcen_dum((2*i_pos)-1)         = Data_xy.bed(i_pos);
    Data_xy.depcen_dum( 2*i_pos   )         = Data_xy.bed(i_pos);
    
    for i_time = 1: no_times
        Data_xy.surcen_dum(i_time,(2*i_pos)-1)         = Data_xy.wl(i_time,i_pos);
        Data_xy.surcen_dum(i_time, 2*i_pos   )         = Data_xy.wl(i_time,i_pos);
        
        Data_xy.zcor_intface_dum(i_time,(2*i_pos)-1,:) = Data_xy.zcen(i_time,i_pos,:);
        Data_xy.zcor_intface_dum(i_time, 2*i_pos   ,:) = Data_xy.zcen(i_time,i_pos,:);
        
        Data_xy.value_dum(i_time,(2*i_pos)-1,:)        = Data_xy.value(i_time,i_pos,:);
        if i_pos ~= size(Data_xy.xcen,1)
            Data_xy.value_dum(i_time, 2*i_pos,:)       = nan;
        end
    end
end

Data_xy.times = Data.times;

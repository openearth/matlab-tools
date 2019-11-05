function Data = EHY_getMapModelData_xy(inputFile,pliFile, varargin)

% 
% Function: Create data needed for plotting of cross section information
modelType = EHY_getModelType(inputFile);

%% Initialise:
OPT.varName         = 'salinity';
OPT.t0              = datenum(2011,12,05);
OPT.tend            = datenum(2011,12,05);
OPT.mergePartitions = 1;
OPT                 = setproperty(OPT,varargin);

%% Read the pli file
thalweg  = readldb(pliFile);

%% Horizontal (x,y) coordinates 
DataXY    = EHY_getGridInfo(inputFile,'XYcen');

%% get "z-data"
[DataZ.val_int,DataZ.val_cen,DataZ.wl,DataZ.wd] = EHY_getMapModelData_construct_zcoordinates(inputFile,modelType,OPT);
no_layers = size(DataZ.val_cen,3);

%% get wanted "varName"-data for all points
DataAll = EHY_getMapModelData(inputFile,OPT);

%% check
dimTextInd = strfind(DataAll.dimensions,',');
if isempty(strfind(lower(DataAll.dimensions(dimTextInd(end)+1:end-1)),'lay'))
    error('Last dimension is not the layer-dimension and that is what this script useData. Please contact Julien.Groenenboom@deltareData.nl')
elseif isempty(strfind(DataAll.dimensions(2:dimTextInd(1)-1),'time'))
    error('First dimension is not the time-dimension and that is what this script useData. Please contact Julien.Groenenboom@deltareData.nl')
end

%% from [m,n] to cells (like FM)
if strcmp(modelType,'d3d')
    modelSize = size(DataAll.val);
    DataAll.val  = reshape(DataAll.val,[modelSize(1) prod(modelSize(2:3)) modelSize(4)]);
    DataZ.val    = reshape(DataZ.val  ,[modelSize(1) prod(modelSize(2:3)) modelSize(4)+1]);  
end

%% Calculate values at pli locations
%  Start with Arccrossing 
[Data.xcor,Data.ycor] = arbcross(DataXY.Xcen,DataXY.Ycen,thalweg.x,thalweg.y);

Data.xcor = Data.xcor(~isnan(Data.xcor));
Data.ycor = Data.ycor(~isnan(Data.ycor));
Data.scor = distance(Data.xcor,Data.ycor);

Data.xcen = (Data.xcor(1:end-1) + Data.xcor(2:end)) ./ 2;
Data.ycen = (Data.ycor(1:end-1) + Data.ycor(2:end)) ./ 2;
Data.scen = (Data.scor(1:end-1) + Data.scor(2:end)) ./ 2;

%  Determine vertival levels at scen locations and corresponding values
for k = 1: no_layers
    Data.zcen (:,k) = griddata(DataXY.Xcen,DataXY.Ycen,DataZ.val_cen(1,:,k),Data.xcen,Data.ycen,'nearest');
    Data.value(:,k) = griddata(DataXY.Xcen,DataXY.Ycen,DataAll.val  (1,:,k),Data.xcen,Data.ycen,'nearest');  
end

Data.wl = griddata(DataXY.Xcen,DataXY.Ycen,DataZ.wl,Data.xcen,Data.ycen,'nearest');
Data.wd = griddata(DataXY.Xcen,DataXY.Ycen,DataZ.wd,Data.xcen,Data.ycen,'nearest');

for i = 1:size(Data.xcen,1)
    Data.value_dum((2*i)-1,:,:)      = Data.value(i,:);
        if i ~= size(Data.xcen,1)
            Data.value_dum( 2*i,:) = nan;
        end
    end
    Data.xcor_dum((2*i)-1)           = Data.xcor(i);
    Data.xcor_dum( 2*i   )           = Data.xcor(i+1);
    Data.ycor_dum((2*i)-1)           = Data.ycor(i);
    Data.ycor_dum( 2*i   )           = Data.ycor(i+1);
    Data.scor_dum((2*i)-1)           = Data.scor(i);
    Data.scor_dum( 2*i   )           = Data.scor(i+1);
    Data.zcor_intface_dum((2*i)-1,:) = Data.zcen(i,:);
    Data.zcor_intface_dum( 2*i   ,:) = Data.zcen(i,:);
    Data.depcen_dum((2*i)-1)         = Data.wd(i);
    Data.depcen_dum( 2*i   )         = Data.wd(i);
    Data.surcen_dum((2*i)-1)         = Data.wl(i);
    Data.surcen_dum( 2*i   )         = Data.wl(i);
end


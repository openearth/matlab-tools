function Data = EHY_getmodeldata_z(inputFile,stat_name,modelType,varargin)

error('working on it - this function is not available yet ... ')
varargin  = varargin{1};

%% get wanted "varName"-data for all layers
deleteInd = [];
for iV = 1:2:length(varargin)
   if ismember(varargin{iV},{'z','zRef','zMethod','layer'})
       deleteInd = [deleteInd iV iV+1];
   end
end
varargin(deleteInd) = [];

% get all layer info (to do: this can be done smarter and thus faster by loading only relevant layers)
varargin{end+1} = 'layer';
varargin{end+1} = 0;

% get data
DataAll = EHY_getmodeldata(inputFile,stat_name,modelType,varargin{:});

%% get "zcen_int"-data
varNameInd = find(strcmp(varargin,'varName'));
varargin{varNameInd+1} = 'Zcen_int';
DataZ = EHY_getmodeldata(inputFile,stat_name,modelType,varargin{:});

%% 




end
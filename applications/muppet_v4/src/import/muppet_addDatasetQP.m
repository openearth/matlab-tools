function varargout=muppet_addDatasetQP(varargin)

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'read'}
                % Read file data
                dataset=varargin{ii+1};
                parameter=[];
                if length(varargin)==3
                    parameter=varargin{ii+1};
                end
                dataset=read(dataset,parameter);
                varargout{1}=dataset;                
            case{'gettimes'}
                times=getTimes;
                varargout{1}=times;
            case{'import'}
                % Import data
                dataset=varargin{ii+1};
                dataset=import(dataset);
                varargout{1}=dataset;
        end
    end
end

%%
function dataset=read(dataset,parameter)

% Set for each dataset:
% parametertimesequal
% parameterstationsequal
% adjustname
%
% Reads for dataset:
% nrparameters
% parameternames;
%
% Reads for each parameter:
% name
% type
% active
% dimensions (nrm,nrn,nrk,nrt,nrstations,stations,nrdomains,domains,nrsubfields,subfields,parametername,active)
% times (if not a time series), stations

% Should move to xml file

switch dataset.filename(end-2:end)
    case{'map','ada'}
        % Delwaq
        if isempty(dataset.lgafile)
            % No lga file specified
            filterspec={'*.lga', '*.lga'};
            [filename, pathname, filterindex] = uigetfile(filterspec);
            dataset.lgafile=[pathname filename];
        end
        fid=qpfopen(dataset.filename,lgafile);
    otherwise
        fid=qpfopen(dataset.filename);
        dataset.lgafile=[];
end

dataproperties=qpread(fid);

if isempty(parameter)
    % Find info for all parameters
    i1=1;
    i2=length(dataproperties);
else
    % Parameter is given (from mup file)
    idata=strmatch(lower(parameter),lower(parameters),'exact');
    i1=idata;
    i2=idata;
end

%% Coordinate System
tp='projected';
if isfield(fid,'SubType')
    switch fid.SubType
        case{'Delft3D-trih'}
        case{'Delft3D-trim'}
            tp=vs_get(fid,'map-const','COORDINATES','quiet');
    end
end
switch lower(deblank(tp))
    case{'spherical'}
        cs.name='WGS 84';
        cs.type='geographic';
    otherwise
        cs.name='unspecified';
        cs.type='projected';        
end

ii=0;

% Get info for each parameter
for j=i1:i2
    
    ii=ii+1;
    
    par=[];

    % Set default parameter properties (just the dimensions)
    par=muppet_setDefaultParameterProperties(par);
    
    par.fid=fid;
    par.lgafile=dataset.lgafile;
    par.dataproperties=dataproperties;    
    par.parametertimesequal=1;
    par.parameterstationsequal=1;
    par.parameterxequal=1;
    par.parameteryequal=1;
    par.parameterzequal=1;
    par.adjustname=1;
    
%    par.parametername=dataproperties(ii).Name;
    par.name=dataproperties(ii).Name;
    
    par.size=qpread(fid,1,dataproperties(ii),'size');
    
    % Bug in qpread?
    par.size=par.size.*dataproperties(ii).DimFlag;

    % Times
    if dataproperties(ii).DimFlag(1)>0 && par.size(1)<1000
        % Only read times when there are less than 1,000
        par.times=qpread(fid,dataproperties(ii),'times');
    end

    % Stations
    if dataproperties(ii).DimFlag(2)>0
        par.stations=qpread(fid,dataproperties(ii),'stations');
    end

    par.coordinatesystem=cs;
    
    if sum(dataproperties(ii).DimFlag)>0

        par.nval=dataproperties(ii).NVal;

        switch dataproperties(ii).NVal
            case 0
                par.quantity='location'; % Grids, open boundaries etc.
            case 1
                par.quantity='scalar';
            case 2
                par.quantity='vector2d';
            case 3
                par.quantity='vector3d';
            case 4
                par.quantity='location';
            case 5
                par.quantity='boolean'; % 0/1 Inactive cells, etc.
            otherwise
                par.quantity='unknown';
        end
        active=1;
    else
        active=0;
    end
        
    dataset.parameters(ii).parameter=par;
    dataset.parameters(ii).parameter.active=active;
    
end

%%
function times=getTimes
% Times
dataset=gui_getUserData;
dataset.times=[];
fid=qpfopen([dataset.pathname dataset.filename]);
dataproperties=qpread(fid);
% Find first parameter with times
for ii=1:length(dataproperties)
    if dataproperties(ii).DimFlag(1)>0
        times=qpread(fid,dataproperties(ii).Name,'times');
        break
    end
end

%%
function dataset=import(dataset)

fid=dataset.fid;

parameter=dataset.parameter;

for ii=1:length(dataset.dataproperties)
    parameternames{ii}=dataset.dataproperties(ii).Name;
end

ipar=strmatch(lower(parameter),lower(parameternames),'exact');
dataproperties=dataset.dataproperties(ipar);

% Read times (if they haven't been read yet)
if dataset.size(1)>0
    % Times available
    if isempty(dataset.times)
        % No times specified yet, read them first
        dataset.times=qpread(fid,dataproperties,'times');
    end
end

% Find data indices
[timestep,istation,m,n,k,idomain]=muppet_findDataIndices(dataset);

%% Load data into structure d
inparg{1}=timestep;
inparg{2}=istation;
inparg{3}=m;
inparg{4}=n;
inparg{5}=k;

arg=[];
narg=0;
for ii=1:5
    if dataset.size(ii)>0
        narg=narg+1;
        arg{narg}=inparg{ii};    
    end
end

% And get the data
switch length(arg)
    case 1
        d=qpread(fid,idomain,dataproperties,'griddata',arg{1});
    case 2
        d=qpread(fid,idomain,dataproperties,'griddata',arg{1},arg{2});
    case{3}
        d=qpread(fid,idomain,dataproperties,'griddata',arg{1},arg{2},arg{3});
    case{4}
        d=qpread(fid,idomain,dataproperties,'griddata',arg{1},arg{2},arg{3},arg{4});
end

% z or d
if isfield(dataproperties,'Loc')
    dataset.location=dataproperties.Loc;
end
dataset.location
% From here on, everything should be the same for each type of datafile
% d must always look like structure as imported from qpread

dataset=muppet_finishImportingDataset(dataset,d,timestep,istation,m,n,k);

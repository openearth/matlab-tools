function [xg,yg,zg]=ddb_ModelMakerToolbox_generateBathymetry(handles,xg,yg,zg,datasets,varargin)

% inputs: model, domain, datasets structure, filename
% get grid data (x,y,z,overwriteoption)
% ddb_interpolateBathymetry (separate function with inputs: bathymetry,datasets,x,y,z,overwriteoption,gridtype)
% adjust model inputs

%% Defaults

overwrite=1;
modeloffset=0;
% Set defaults for datasets
for ii=1:length(datasets)
    datasets=filldatasets(datasets,ii,'zmin',-100000);
    datasets=filldatasets(datasets,ii,'zmax',100000);
    datasets=filldatasets(datasets,ii,'startdates',floor(now));
    datasets=filldatasets(datasets,ii,'searchintervals',-1e5);
    datasets=filldatasets(datasets,ii,'verticaloffset',0);
    datasets=filldatasets(datasets,ii,'verticaloffset',0);
    datasets=filldatasets(datasets,ii,'internaldiff',0);
    datasets=filldatasets(datasets,ii,'internaldiffusionrange',[-20000 20000]);
end

%% Read input arguments
for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'overwrite'}
                overwrite=varargin{i+1};
            case{'gridtype'}
                gridtype=varargin{i+1};                
            case{'modeloffset'}
                modeloffset=varargin{i+1};                
        end
    end
end

%% Interpolate onto grid
zg=ddb_interpolateBathymetry2(handles.bathymetry,datasets,xg,yg,zg,modeloffset,overwrite,gridtype, ...
    handles.toolbox.modelmaker.bathymetry.internalDiffusion,handles.screenParameters.coordinateSystem);


%% Fill datasets
function datasets=filldatasets(datasets,ii,var,val)
if ~isfield(datasets(ii),var)
    datasets(ii).(var)=val;
elseif isempty(datasets(ii).(var))
    datasets(ii).(var)=val;
end


function handles=ddb_initializeTiling(handles,varargin)

ii=strmatch('Tiling',{handles.Toolbox(:).name},'exact');
if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            handles.Toolbox(ii).longName='Tiling';
            return
    end
end

%% Bathymetry

handles.Toolbox(ii).bathymetry.x0=0;
handles.Toolbox(ii).bathymetry.y0=0;
handles.Toolbox(ii).bathymetry.nx=300;
handles.Toolbox(ii).bathymetry.ny=300;
handles.Toolbox(ii).bathymetry.nrZoom=5;

handles.Toolbox(ii).bathymetry.fileName='';
handles.Toolbox(ii).bathymetry.dataName='';
handles.Toolbox(ii).bathymetry.dataDir=[handles.bathyDir];

handles.Toolbox(ii).bathymetry.EPSGcode                     = 4326;
handles.Toolbox(ii).bathymetry.EPSGname                     = 'WGS 84';
handles.Toolbox(ii).bathymetry.EPSGtype                     = 'geographic';
handles.Toolbox(ii).bathymetry.vertCoordName                = 'MSL';
handles.Toolbox(ii).bathymetry.vertCoordLevel               = 0.0;
handles.Toolbox(ii).bathymetry.nc_library                   = 'matlab';
handles.Toolbox(ii).bathymetry.type                         = 'float';

handles.Toolbox(ii).bathymetry.attributes.conventions                  = 'CF-1.4';
handles.Toolbox(ii).bathymetry.attributes.CF_featureType               = 'grid';
handles.Toolbox(ii).bathymetry.attributes.title                        = 'Name of data set';
handles.Toolbox(ii).bathymetry.attributes.institution                  = 'Institution';
handles.Toolbox(ii).bathymetry.attributes.source                       = 'Source';
handles.Toolbox(ii).bathymetry.attributes.history                      = 'created by : ';
handles.Toolbox(ii).bathymetry.attributes.references                   = 'No reference material available';
handles.Toolbox(ii).bathymetry.attributes.comment                      = 'none';
handles.Toolbox(ii).bathymetry.attributes.email                        = 'Your email here';
handles.Toolbox(ii).bathymetry.attributes.version                      = '1.0';
handles.Toolbox(ii).bathymetry.attributes.terms_for_use                = 'Use as you like';
handles.Toolbox(ii).bathymetry.attributes.disclaimer                   = 'These data are made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';


%% Shoreline

handles.Toolbox(ii).shoreline.EPSGcode                     = 4326;
handles.Toolbox(ii).shoreline.EPSGname                     = 'WGS 84';
handles.Toolbox(ii).shoreline.EPSGtype                     = 'geographic';
handles.Toolbox(ii).shoreline.conventions                  = 'CF-1.4';
handles.Toolbox(ii).shoreline.CF_featureType               = 'polyline';
handles.Toolbox(ii).shoreline.title                        = 'Name of data set';
handles.Toolbox(ii).shoreline.institution                  = 'Institution';
handles.Toolbox(ii).shoreline.source                       = 'Source';
handles.Toolbox(ii).shoreline.history                      = 'created by';
handles.Toolbox(ii).shoreline.references                   = 'No reference material available';
handles.Toolbox(ii).shoreline.comment                      = 'Comments';
handles.Toolbox(ii).shoreline.email                        = 'Your email here';
handles.Toolbox(ii).shoreline.version                      = '1.0';
handles.Toolbox(ii).shoreline.terms_for_use                = 'Use as you like';
handles.Toolbox(ii).shoreline.disclaimer                   = 'These data are made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';
handles.Toolbox(ii).shoreline.nc_library                   = 'matlab';
handles.Toolbox(ii).shoreline.type                         = 'float';

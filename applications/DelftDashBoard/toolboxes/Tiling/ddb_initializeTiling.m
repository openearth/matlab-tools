function handles=ddb_initializeTiling(handles,varargin)

ii=strmatch('Tiling',{handles.Toolbox(:).Name},'exact');
if nargin>1
    switch varargin{1}
        case{'test'}
            return
        case{'veryfirst'}
            handles.Toolbox(ii).LongName='Tiling';
            return
    end
end

%% Bathymetry

handles.Toolbox(ii).Bathymetry.x0=0;
handles.Toolbox(ii).Bathymetry.y0=0;
handles.Toolbox(ii).Bathymetry.nx=300;
handles.Toolbox(ii).Bathymetry.ny=300;
handles.Toolbox(ii).Bathymetry.nrZoom=5;

handles.Toolbox(ii).Bathymetry.fileName='';
handles.Toolbox(ii).Bathymetry.dataName='';
handles.Toolbox(ii).Bathymetry.dataDir=[handles.BathyDir];

handles.Toolbox(ii).Bathymetry.EPSGcode                     = 4326;
handles.Toolbox(ii).Bathymetry.EPSGname                     = 'WGS 84';
handles.Toolbox(ii).Bathymetry.EPSGtype                     = 'geographic';
handles.Toolbox(ii).Bathymetry.VertCoordName                = 'MSL';
handles.Toolbox(ii).Bathymetry.VertCoordLevel               = 0.0;
handles.Toolbox(ii).Bathymetry.nc_library                   = 'matlab';
handles.Toolbox(ii).Bathymetry.type                         = 'float';

handles.Toolbox(ii).Bathymetry.Attributes.Conventions                  = 'CF-1.4';
handles.Toolbox(ii).Bathymetry.Attributes.CF_featureType               = 'grid';
handles.Toolbox(ii).Bathymetry.Attributes.title                        = 'Name of data set';
handles.Toolbox(ii).Bathymetry.Attributes.institution                  = 'Institution';
handles.Toolbox(ii).Bathymetry.Attributes.source                       = 'Source';
handles.Toolbox(ii).Bathymetry.Attributes.history                      = 'created by : ';
handles.Toolbox(ii).Bathymetry.Attributes.references                   = 'No reference material available';
handles.Toolbox(ii).Bathymetry.Attributes.comment                      = 'none';
handles.Toolbox(ii).Bathymetry.Attributes.email                        = 'Your email here';
handles.Toolbox(ii).Bathymetry.Attributes.version                      = '1.0';
handles.Toolbox(ii).Bathymetry.Attributes.terms_for_use                = 'Use as you like';
handles.Toolbox(ii).Bathymetry.Attributes.disclaimer                   = 'These data are made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';


%% Shoreline

handles.Toolbox(ii).Shoreline.EPSGcode                     = 4326;
handles.Toolbox(ii).Shoreline.EPSGname                     = 'WGS 84';
handles.Toolbox(ii).Shoreline.EPSGtype                     = 'geographic';
handles.Toolbox(ii).Shoreline.Conventions                  = 'CF-1.4';
handles.Toolbox(ii).Shoreline.CF_featureType               = 'polyline';
handles.Toolbox(ii).Shoreline.title                        = 'Name of data set';
handles.Toolbox(ii).Shoreline.institution                  = 'Institution';
handles.Toolbox(ii).Shoreline.source                       = 'Source';
handles.Toolbox(ii).Shoreline.history                      = 'created by';
handles.Toolbox(ii).Shoreline.references                   = 'No reference material available';
handles.Toolbox(ii).Shoreline.comment                      = 'Comments';
handles.Toolbox(ii).Shoreline.email                        = 'Your email here';
handles.Toolbox(ii).Shoreline.version                      = '1.0';
handles.Toolbox(ii).Shoreline.terms_for_use                = 'Use as you like';
handles.Toolbox(ii).Shoreline.disclaimer                   = 'These data are made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';
handles.Toolbox(ii).Shoreline.nc_library                   = 'matlab';
handles.Toolbox(ii).Shoreline.type                         = 'float';

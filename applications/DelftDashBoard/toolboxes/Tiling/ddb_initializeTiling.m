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

handles.Toolbox(ii).Input.bathymetry.x0=0;
handles.Toolbox(ii).Input.bathymetry.y0=0;
handles.Toolbox(ii).Input.bathymetry.nx=300;
handles.Toolbox(ii).Input.bathymetry.ny=300;
handles.Toolbox(ii).Input.bathymetry.nrZoom=5;

handles.Toolbox(ii).Input.bathymetry.fileName='';
handles.Toolbox(ii).Input.bathymetry.dataName='';
handles.Toolbox(ii).Input.bathymetry.dataDir=[handles.bathyDir];

handles.Toolbox(ii).Input.bathymetry.EPSGcode                     = 4326;
handles.Toolbox(ii).Input.bathymetry.EPSGname                     = 'WGS 84';
handles.Toolbox(ii).Input.bathymetry.EPSGtype                     = 'geographic';
handles.Toolbox(ii).Input.bathymetry.vertCoordName                = 'MSL';
handles.Toolbox(ii).Input.bathymetry.vertCoordLevel               = 0.0;
handles.Toolbox(ii).Input.bathymetry.nc_library                   = 'matlab';
handles.Toolbox(ii).Input.bathymetry.type                         = 'float';

handles.Toolbox(ii).Input.bathymetry.radioGeo                     = 1;
handles.Toolbox(ii).Input.bathymetry.radioProj                    = 0;

handles.Toolbox(ii).Input.bathymetry.attributes.conventions                  = 'CF-1.4';
handles.Toolbox(ii).Input.bathymetry.attributes.CF_featureType               = 'grid';
handles.Toolbox(ii).Input.bathymetry.attributes.title                        = 'Name of data set';
handles.Toolbox(ii).Input.bathymetry.attributes.institution                  = 'Institution';
handles.Toolbox(ii).Input.bathymetry.attributes.source                       = 'Source';
handles.Toolbox(ii).Input.bathymetry.attributes.history                      = 'created by : ';
handles.Toolbox(ii).Input.bathymetry.attributes.references                   = 'No reference material available';
handles.Toolbox(ii).Input.bathymetry.attributes.comment                      = 'none';
handles.Toolbox(ii).Input.bathymetry.attributes.email                        = 'Your email here';
handles.Toolbox(ii).Input.bathymetry.attributes.version                      = '1.0';
handles.Toolbox(ii).Input.bathymetry.attributes.terms_for_use                = 'Use as you like';
handles.Toolbox(ii).Input.bathymetry.attributes.disclaimer                   = 'These data are made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';


%% Shoreline

handles.Toolbox(ii).Input.shoreline.EPSGcode                     = 4326;
handles.Toolbox(ii).Input.shoreline.EPSGname                     = 'WGS 84';
handles.Toolbox(ii).Input.shoreline.EPSGtype                     = 'geographic';
handles.Toolbox(ii).Input.shoreline.conventions                  = 'CF-1.4';
handles.Toolbox(ii).Input.shoreline.CF_featureType               = 'polyline';
handles.Toolbox(ii).Input.shoreline.title                        = 'Name of data set';
handles.Toolbox(ii).Input.shoreline.institution                  = 'Institution';
handles.Toolbox(ii).Input.shoreline.source                       = 'Source';
handles.Toolbox(ii).Input.shoreline.history                      = 'created by';
handles.Toolbox(ii).Input.shoreline.references                   = 'No reference material available';
handles.Toolbox(ii).Input.shoreline.comment                      = 'Comments';
handles.Toolbox(ii).Input.shoreline.email                        = 'Your email here';
handles.Toolbox(ii).Input.shoreline.version                      = '1.0';
handles.Toolbox(ii).Input.shoreline.terms_for_use                = 'Use as you like';
handles.Toolbox(ii).Input.shoreline.disclaimer                   = 'These data are made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';
handles.Toolbox(ii).Input.shoreline.nc_library                   = 'matlab';
handles.Toolbox(ii).Input.shoreline.type                         = 'float';

function handles=ddb_generateBathymetry_Delft3DWAVE(handles,id,varargin)
% Interpolates bathymetry, save depth file and plots the data for
% Delft3D-WAVE

% Default (use background bathymetry)
datasets{1}=handles.screenParameters.backgroundBathymetry;
zmin=-100000;
zmax=100000;
startdates=floor(now);
searchintervals=-1e5;
filename=[];
verticaloffsets=0;
verticaloffset=0;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'datasets'}
                datasets=varargin{i+1};
            case{'zmin'}
                zmin=varargin{i+1};
            case{'zmax'}
                zmax=varargin{i+1};
            case{'startdates'}
                startdates=varargin{i+1};
            case{'searchintervals'}
                searchintervals=varargin{i+1};
            case{'verticaloffsets'}
                verticaloffsets=varargin{i+1};
            case{'verticaloffset'}
                verticaloffset=varargin{i+1};
            case{'filename'}
                filename=varargin{i+1};
        end
    end
end

if handles.Model(md).Input.domains(id).mmax>0

    if isempty(filename)
        % Get file name
        [filename, pathname, filterindex] = uiputfile('*.dep', 'Depth File Name',[handles.Model(md).Input.attname '.dep']);
        if pathname==0
            return
        end
    end
    
    xg=handles.Model(md).Input.domains(id).gridx;
    yg=handles.Model(md).Input.domains(id).gridy;
    
    % Check if there is already data in depth matrix
    dmax=max(max(handles.Model(md).Input.domains(id).depth));
    if isempty(dmax)
        dmax=NaN;
    end
    
    if isnan(dmax)
        opt='overwrite';
    else
        ButtonName = questdlg('Overwrite existing bathymetry?', ...
            'Delete existing bathymetry', ...
            'Cancel', 'No', 'Yes', 'Yes');
        switch ButtonName,
            case 'Cancel',
                return;
            case 'No',
                opt='combine';
            case 'Yes',
                opt='overwrite';
        end
    end
    
    wb = waitbox('Generating bathymetry ...');
        
    z = ddb_interpolateBathymetry(handles.bathymetry,xg,yg,'datasets',datasets,'startdates',startdates,'searchintervals',searchintervals, ...
        'zmin',zmin,'zmax',zmax,'verticaloffsets',verticaloffsets,'verticaloffset',verticaloffset,'coordinatesystem',handles.screenParameters.coordinateSystem);
    
    switch opt
        case{'overwrite'}
            handles.Model(md).Input.domains(id).depth=z;
        case{'combine'}
            handles.Model(md).Input.domains(id).depth(isnan(handles.Model(md).Input.domains(id).depth))=z(isnan(handles.Model(md).Input.domains(id).depth));
    end

    handles.Model(md).Input.domains(id).bedlevel=filename;
    handles.Model(md).Input.domains(id).depthsource='file';

    ddb_wldep('write',filename,handles.Model(md).Input.domains(id).depth);
        
    try
        close(wb);
    end
    
    handles=ddb_Delft3DWAVE_plotBathy(handles,'plot','wavedomain',id);
        
else
    ddb_giveWarning('Warning','First generate or load a grid');
end

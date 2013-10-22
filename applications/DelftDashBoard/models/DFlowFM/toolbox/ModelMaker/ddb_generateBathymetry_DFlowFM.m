function handles=ddb_generateBathymetry_DFlowFM(handles,id,varargin)
% Interpolates bathymetry, save depth file and plots the data for
% Delft3D-FLOW

% Default (use background bathymetry)
datasets{1}=handles.screenParameters.backgroundBathymetry;
zmin=-100000;
zmax=100000;
startdates=floor(now);
searchintervals=-1e5;
verticaloffsets=0;
verticaloffset=0;
internaldiff=0;
internaldiffusionrange=[-20000 20000];

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
            case{'internaldiffusion'}
                internaldiff=varargin{i+1};
            case{'internaldiffusionrange'}
                internaldiffusionrange=varargin{i+1};
        end
    end
end

if ~isempty(handles.Model(md).Input(id).netstruc)
    
    xg=handles.Model(md).Input(id).netstruc.nodeX;
    yg=handles.Model(md).Input(id).netstruc.nodeX;
    
    % Check if there is already data in depth matrix
    dmax=max(handles.Model(md).Input(id).netstruc.nodeZ);
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
        'zmin',zmin,'zmax',zmax,'verticaloffsets',verticaloffsets,'verticaloffset',verticaloffset, ...
        'coordinatesystem',handles.screenParameters.coordinateSystem,'internaldiffusion',internaldiff,'internaldiffusionrange',internaldiffusionrange, ...
        'structuredgrid',0);
    
    switch opt
        case{'overwrite'}
            handles.Model(md).Input(id).netstruc.nodeZ=z;
        case{'combine'}
            handles.Model(md).Input(id).netstruc.nodeZ(isnan(handles.Model(md).Input(id).netstruc.nodeZ))=z(isnan(handles.Model(md).Input(id).netstruc.nodeZ));
    end
        
    netStruc2nc(handles.Model(md).Input(id).netfile,handles.Model(md).Input(id).netstruc,'cstype',handles.screenParameters.coordinateSystem.type);

    try
        close(wb);
    end
            
else
    ddb_giveWarning('Warning','First generate or load a grid');
end

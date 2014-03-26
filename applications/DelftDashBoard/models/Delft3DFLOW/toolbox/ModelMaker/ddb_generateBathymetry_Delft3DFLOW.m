function handles=ddb_generateBathymetry_Delft3DFLOW(handles,id,varargin)
% Interpolates bathymetry, save depth file and plots the data for
% Delft3D-FLOW

% Default (use background bathymetry)
datasets{1}=handles.screenParameters.backgroundBathymetry;
zmin=-100000;
zmax=100000;
startdates=floor(now);
searchintervals=-1e5;
filename=[];
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

if handles.model.delft3dflow.domain(id).MMax>0

    if isempty(filename)
        % Get file name
        [filename, pathname, filterindex] = uiputfile('*.dep', 'Depth File Name',[handles.model.delft3dflow.domain(ad).attName '.dep']);
        if pathname==0
            return
        end
    end
    
    switch lower(handles.model.delft3dflow.domain(id).dpsOpt)
        case{'dp'}
            xg=handles.model.delft3dflow.domain(id).gridXZ;
            yg=handles.model.delft3dflow.domain(id).gridYZ;
        otherwise
            xg=handles.model.delft3dflow.domain(id).gridX;
            yg=handles.model.delft3dflow.domain(id).gridY;
    end
    
    % Check if there is already data in depth matrix
    dmax=max(max(handles.model.delft3dflow.domain(id).depth));
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
        'coordinatesystem',handles.screenParameters.coordinateSystem,'internaldiffusion',internaldiff,'internaldiffusionrange',internaldiffusionrange);
    
    switch opt
        case{'overwrite'}
            handles.model.delft3dflow.domain(id).depth=z;
        case{'combine'}
            handles.model.delft3dflow.domain(id).depth(isnan(handles.model.delft3dflow.domain(id).depth))=z(isnan(handles.model.delft3dflow.domain(id).depth));
    end
    
    % Fill borders
    switch lower(handles.model.delft3dflow.domain(id).dpsOpt)
        case{'dp'}
            handles.model.delft3dflow.domain(id).depth(:,1)=handles.model.delft3dflow.domain(id).depth(:,2);
            handles.model.delft3dflow.domain(id).depth(1,:)=handles.model.delft3dflow.domain(id).depth(2,:);
    end
    
    z=handles.model.delft3dflow.domain(id).depth;
    
    handles.model.delft3dflow.domain(id).depthZ=getDepthZ(z,handles.model.delft3dflow.domain(id).dpsOpt);

    handles.model.delft3dflow.domain(id).depFile=filename;

    handles.model.delft3dflow.domain(id).depthSource='file';

    ddb_wldep('write',filename,z);
        
    try
        close(wb);
    end
    
    handles=ddb_Delft3DFLOW_plotBathy(handles,'plot','domain',id);
        
else
    ddb_giveWarning('Warning','First generate or load a grid');
end

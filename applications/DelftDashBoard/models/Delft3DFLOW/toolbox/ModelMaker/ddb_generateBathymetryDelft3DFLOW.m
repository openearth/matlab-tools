function handles=ddb_generateBathymetryDelft3DFLOW(handles,id,varargin)

if ~isempty(varargin)
    % Check if routine exists
    if strcmpi(varargin{1},'ddb_test')
        return
    end
end

if ~isempty(handles.Model(md).Input(id).GrdFile)

    dpori=handles.Model(md).Input(id).Depth;
    dmax=max(max(dpori));

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

    AttName=get(handles.GUIHandles.EditAttributeName,'String');

    % Generate bathymetry

    xx=handles.GUIData.x;
    yy=handles.GUIData.y;
    zz=handles.GUIData.z;
    
    dpsopt=handles.Model(md).Input(id).DpsOpt;

    switch lower(dpsopt)
        case{'DP'}
            x=handles.Model(md).Input(id).GridXZ;
            y=handles.Model(md).Input(id).GridYZ;
        otherwise
            x=handles.Model(md).Input(id).GridX;
            y=handles.Model(md).Input(id).GridY;
    end

    x(isnan(x))=0;
    y(isnan(y))=0;
    
    z=interp2(xx,yy,zz,x,y);
    
    switch opt
        case{'overwrite'}
            handles.Model(md).Input(id).Depth=z;
        case{'combine'}
            handles.Model(md).Input(id).Depth(isnan(handles.Model(md).Input(id).Depth))=z(isnan(handles.Model(md).Input(id).Depth));
    end

    handles.Model(md).Input(id).DepthZ=GetDepthZ(z,dpsopt);

    ddb_wldep('write',[AttName '.dep'],z);

    handles.Model(md).Input(id).DepFile=[AttName '.dep'];

    setHandles(handles);
    
    try
        close(wb);
    end

    ddb_plotFlowBathymetry(handles,'plot',id);

else
    GiveWarning('Warning','First generate or load a grid');
end

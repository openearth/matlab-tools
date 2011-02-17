function handles=ddb_generateBathymetryDelft3DFLOW(handles,id,varargin)

if ~isempty(varargin)
    % Check if routine exists
    if strcmpi(varargin{1},'ddb_test')
        return
    end
end

if ~isempty(handles.Model(md).Input(id).grdFile)

    dpori=handles.Model(md).Input(id).depth;
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

    attName=handles.Model(md).Input(id).attName;

    % Generate bathymetry

    xx=handles.GUIData.x;
    yy=handles.GUIData.y;
    zz=handles.GUIData.z;
    
    dpsopt=handles.Model(md).Input(id).dpsOpt;

    switch lower(dpsopt)
        case{'dp'}
            x=handles.Model(md).Input(id).gridXZ;
            y=handles.Model(md).Input(id).gridYZ;
        otherwise
            x=handles.Model(md).Input(id).gridX;
            y=handles.Model(md).Input(id).gridY;
    end

    x(isnan(x))=0;
    y(isnan(y))=0;
    
    z=interp2(xx,yy,zz,x,y);
    
    switch opt
        case{'overwrite'}
            handles.Model(md).Input(id).depth=z;
        case{'combine'}
            handles.Model(md).Input(id).depth(isnan(handles.Model(md).Input(id).depth))=z(isnan(handles.Model(md).Input(id).depth));
    end

    z=handles.Model(md).Input(id).depth;
    
    handles.Model(md).Input(id).depthZ=GetDepthZ(z,dpsopt);

    ddb_wldep('write',[attName '.dep'],z);

    handles.Model(md).Input(id).depFile=[attName '.dep'];

    setHandles(handles);
    
    try
        close(wb);
    end

    ddb_plotFlowBathymetry(handles,'plot',id);

else
    GiveWarning('Warning','First generate or load a grid');
end

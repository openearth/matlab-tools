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

%     xx=handles.GUIData.x;
%     yy=handles.GUIData.y;
%     zz=handles.GUIData.z;
    
    switch lower(handles.Model(md).Input(id).dpsOpt)
        case{'dp'}
            xg=handles.Model(md).Input(id).gridXZ;
            yg=handles.Model(md).Input(id).gridYZ;
        otherwise
            xg=handles.Model(md).Input(id).gridX;
            yg=handles.Model(md).Input(id).gridY;
    end
    
    % Convert grid to cs of background image
    coord=handles.screenParameters.coordinateSystem;
    iac=strmatch(lower(handles.screenParameters.backgroundBathymetry),lower(handles.bathymetry.datasets),'exact');
    dataCoord.name=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.name;
    dataCoord.type=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.type;
    [xg,yg]=ddb_coordConvert(xg,yg,coord,dataCoord);

    % Find minimum grid resolution
    [dmin,dmax]=findMinMaxGridSize(xg,yg,'cstype',handles.screenParameters.coordinateSystem.type);
    xl(1)=min(min(xg));
    xl(2)=max(max(xg));
    yl(1)=min(min(yg));
    yl(2)=max(max(yg));
    dbuf=(xl(2)-xl(1))/10;
    xl(1)=xl(1)-dbuf;
    xl(2)=xl(2)+dbuf;
    yl(1)=yl(1)-dbuf;
    yl(2)=yl(2)+dbuf;
%    dmin=15000;
    [xx,yy,zz,ok]=ddb_getBathy(handles,xl,yl,'bathymetry',handles.screenParameters.backgroundBathymetry,'maxcellsize',dmin);
    
    xg(isnan(xg))=0;
    yg(isnan(yg))=0;
    
    z=interp2(xx,yy,zz,xg,yg);
%    z=gridcellaveraging2(xx,yy,zz,xg,yg,dmin/111111,'max');
    
    switch opt
        case{'overwrite'}
            handles.Model(md).Input(id).depth=z;
        case{'combine'}
            handles.Model(md).Input(id).depth(isnan(handles.Model(md).Input(id).depth))=z(isnan(handles.Model(md).Input(id).depth));
    end

    z=handles.Model(md).Input(id).depth;
    
    handles.Model(md).Input(id).depthZ=getDepthZ(z,handles.Model(md).Input(id).dpsOpt);

    ddb_wldep('write',[attName '.dep'],z);

    handles.Model(md).Input(id).depFile=[attName '.dep'];


%    setHandles(handles);
    
    try
        close(wb);
    end
    
    handles=ddb_Delft3DFLOW_plotBathy(handles,'plot','domain',id);

%    ddb_plotFlowBathymetry(handles,'plot',id);

else
    GiveWarning('Warning','First generate or load a grid');
end

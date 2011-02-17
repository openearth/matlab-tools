function handles=ddb_coordConvertDelft3DFLOW(handles)

ddb_plotDelft3DFLOW(handles,'delete');

if handles.ConvertModelData
    NewSystem=handles.screenParameters.CoordinateSystem;
    OldSystem=handles.screenParameters.OldCoordinateSystem;

    for id=1:handles.GUIData.nrFlowDomains

        if ~isempty(handles.Model(md).Input(id).grdFile)

            %% Grid
            [filename, pathname, filterindex] = uiputfile('*.grd',['Select grid file for domain ' handles.Model(md).Input(id).runid],handles.Model(md).Input(id).grdFile);
            if pathname~=0
                curdir=[lower(cd) '\'];
                if ~strcmpi(curdir,pathname)
                    filename=[pathname filename];
                end
            else
                filename=handles.Model(md).Input(id).grdFile;
            end

            x=handles.Model(handles.activeModel.Nr).Input(id).gridX;
            y=handles.Model(handles.activeModel.Nr).Input(id).gridY;
            [x,y]=ddb_coordConvert(x,y,OldSystem,NewSystem);
            handles.Model(handles.ActiveModel.Nr).Input(id).gridX=x;
            handles.Model(handles.ActiveModel.Nr).Input(id).gridY=y;

            handles.Model(md).Input(id).grdFile=filename;
            encfile=[filename(1:end-3) 'enc'];
            if ~strcmpi(handles.Model(md).Input(id).encFile,encfile)
                copyfile(handles.Model(md).Input(id).encFile,encfile);
            end
            handles.Model(md).Input(id).encFile=encfile;

            if strcmpi(handles.screenParameters.CoordinateSystem.Type,'geographic')
                coord='Spherical';
            else
                coord='Cartesian';
            end
            ddb_wlgrid('write','FileName',filename,'X',x,'Y',y,'CoordinateSystem',coord);

            %% Open boundaries      
            for ib=1:handles.Model(md).Input(id).nrOpenBoundaries
                [xb,yb,zb]=ddb_getBoundaryCoordinates(handles,id,ib);
                handles.Model(md).Input(id).openBoundaries(ib).x=xb;
                handles.Model(md).Input(id).openBoundaries(ib).y=yb;
            end
        
        end
    end
    ddb_plotDelft3DFLOW(handles,'plot');
else
    handles=ddb_initializeDelft3DFLOW(handles);
end

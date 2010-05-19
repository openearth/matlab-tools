function handles=ddb_coordConvertDelft3DFLOW(handles)

ddb_plotDelft3DFLOW(handles,'delete');

if handles.ConvertModelData
    NewSystem=handles.ScreenParameters.CoordinateSystem;
    OldSystem=handles.ScreenParameters.OldCoordinateSystem;

    for id=1:handles.GUIData.NrFlowDomains

        if ~isempty(handles.Model(md).Input(id).GrdFile)

            %% Grid
            [filename, pathname, filterindex] = uiputfile('*.grd',['Select grid file for domain ' handles.Model(md).Input(id).Runid],handles.Model(md).Input(id).GrdFile);
            if pathname~=0
                curdir=[lower(cd) '\'];
                if ~strcmpi(curdir,pathname)
                    filename=[pathname filename];
                end
            else
                filename=handles.Model(md).Input(id).GrdFile;
            end

            x=handles.Model(handles.ActiveModel.Nr).Input(id).GridX;
            y=handles.Model(handles.ActiveModel.Nr).Input(id).GridY;
            [x,y]=ddb_coordConvert(x,y,OldSystem,NewSystem);
            handles.Model(handles.ActiveModel.Nr).Input(id).GridX=x;
            handles.Model(handles.ActiveModel.Nr).Input(id).GridY=y;

            handles.Model(md).Input(id).GrdFile=filename;
            encfile=[filename(1:end-3) 'enc'];
            if ~strcmpi(handles.Model(md).Input(id).EncFile,encfile)
                copyfile(handles.Model(md).Input(id).EncFile,encfile);
            end
            handles.Model(md).Input(id).EncFile=encfile;

            if strcmpi(handles.ScreenParameters.CoordinateSystem.Type,'geographic')
                coord='Spherical';
            else
                coord='Cartesian';
            end
            ddb_wlgrid('write','FileName',filename,'X',x,'Y',y,'CoordinateSystem',coord);

            %% Open boundaries      
            for ib=1:handles.Model(md).Input(id).NrOpenBoundaries
                [xb,yb,zb]=ddb_getBoundaryCoordinates(handles,id,ib);
                handles.Model(md).Input(id).OpenBoundaries(ib).X=xb;
                handles.Model(md).Input(id).OpenBoundaries(ib).Y=yb;
            end
        
        end
    end
    ddb_plotDelft3DFLOW(handles,'plot');
else
    handles=ddb_initializeDelft3DFLOW(handles);
end

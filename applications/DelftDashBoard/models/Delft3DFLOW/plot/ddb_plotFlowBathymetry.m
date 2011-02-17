function ddb_plotFlowBathymetry(handles,opt,id)

switch lower(opt)

    case{'plot'}

        h=findobj(gca,'Tag','FlowBathymetry','UserData',id);
        delete(h);

        if size(handles.Model(md).Input(ad).depth,1)>0

            clims=get(gca,'CLim');
            zmin=clims(1);
            zmax=clims(2);
            
            colormap(ddb_getColors(handles.mapData.colorMaps.earth,64)*255);
            
            caxis([zmin zmax]);
            
            x=handles.Model(md).Input(id).gridX;
            y=handles.Model(md).Input(id).gridY;
            z=handles.Model(md).Input(id).depth;

            z0=zeros(size(z));
            bathy=surface(x,y,z);
            set(bathy,'FaceColor','flat');
            set(bathy,'HitTest','off');
            set(bathy,'Tag','FlowBathymetry','UserData',id);
            set(bathy,'EdgeColor','none');
            set(bathy,'ZData',z0);
            if strcmp(get(findobj((get(handles.GUIHandles.Menu.View.Model,'Children')),'Label','Bathymetry'),'Checked'),'off')
                set(bathy,'Visible','off');
            end
        end

    case{'delete'}
        h=findobj(gca,'Tag','FlowBathymetry','UserData',id);
        delete(h);

    case{'activate'}
        h=findobj(gca,'Tag','Bathymetry','UserData',id);
        if ~isempty(h)
            set(h,'Visible','on');
        end

    case{'deactivate'}
        h=findobj(gca,'Tag','Bathymetry','UserData',id);
        if ~isempty(h)
            set(h,'Visible','off');
        end

end


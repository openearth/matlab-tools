function ddb_plotFlowBathymetry(handles,opt,id)

switch lower(opt)

    case{'plot'}

        h=findall(gca,'Tag','FlowBathymetry','UserData',id);
        delete(h);

        if size(handles.Model(md).Input(handles.ActiveDomain).Depth,1)>0

            clims=get(gca,'CLim');
            zmin=clims(1);
            zmax=clims(2);
            
            colormap(ddb_getColors(handles.GUIData.ColorMaps.Earth,64)*255);
            
            caxis([zmin zmax]);
            
            x=handles.Model(md).Input(id).GridX;
            y=handles.Model(md).Input(id).GridY;
            z=handles.Model(md).Input(id).Depth;

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
        h=findall(gca,'Tag','FlowBathymetry','UserData',id);
        delete(h);

    case{'activate'}
        h=findall(gca,'Tag','Bathymetry','UserData',id);
        if ~isempty(h)
            set(h,'Visible','on');
        end

    case{'deactivate'}
        h=findall(gca,'Tag','Bathymetry','UserData',id);
        if ~isempty(h)
            set(h,'Visible','off');
        end

end


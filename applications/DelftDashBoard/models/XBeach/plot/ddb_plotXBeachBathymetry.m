function ddb_plotXBeachBathymetry(handles,id)

ii=strmatch('XBeach',{handles.Model.name},'exact');

% switch lower(opt)

%     case{'plot'}

        h=findall(gca,'Tag','XBeachBathymetry','UserData',id);
        delete(h);

        if size(handles.Model(ii).Input(ad).Depth,1)>0
            clims=get(gca,'CLim');
            zmin=clims(1);
            zmax=clims(2);
%             colormap(handles.GUIData.ColorMaps.Earth);
            colormap(jet)
            caxis([zmin zmax]);
            x=handles.Model(ii).Input(id).GridX;
            y=handles.Model(ii).Input(id).GridY;
            z=handles.Model(ii).Input(id).Depth;
            
            % transform to world cooardinates
            xori = handles.Model(ii).Input(id).xori;
            yori = handles.Model(ii).Input(id).yori;
            alfa = handles.Model(ii).Input(id).alfa;
            xw =  xori+x*cos(alfa)-y*sin(alfa);
            yw =  yori+x*sin(alfa)+y*cos(alfa);

            z0=zeros(size(z));
            bathy=surface(xw,yw,z);
            set(bathy,'FaceColor','flat');
            set(bathy,'HitTest','off');
            set(bathy,'Tag','XBeachBathymetry','UserData',id);
            set(bathy,'EdgeColor','none');
            set(bathy,'ZData',z0);
        end

%     case{'delete'}
%         h=findall(gca,'Tag','XBeachBathymetry','UserData',id);
%         delete(h);
% 
%     case{'activate'}
%         h=findall(gca,'Tag','XBeachBathymetry','UserData',id);
%         if ~isempty(h)
%             set(h,'Visible','on');
%         end
% 
%     case{'deactivate'}
%         h=findall(gca,'Tag','XBeachBathymetry','UserData',id);
%         if ~isempty(h)
%             set(h,'Visible','off');
%         end

% end


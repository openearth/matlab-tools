function muppet_makeSubplot(handles,ifig,j)

nodat=handles.figures(ifig).figure.subplots(j).subplot.nrdatasets;

leftaxis=axes;

for k=1:nodat
    % Find dataset numbers
    handles.figures(ifig).figure.subplots(j).subplot.datasets(k).dataset.number=muppet_findDatasetNumber(handles, ...
        handles.figures(ifig).figure.subplots(j).subplot.datasets(k).dataset.name);
    nr=handles.figures(ifig).figure.subplots(j).subplot.datasets(k).dataset.number;
    
    % Convert data
    switch handles.figures(ifig).figure.subplots(j).subplot.projection
        case{'mercator'}
            handles.datasets(nr).dataset.y=merc(handles.datasets(nr).dataset.y);
        case{'albers'}
            plt=handles.figures(ifig).figure.subplots(j).subplot;
            x=handles.datasets(nr).dataset.x;
            y=handles.datasets(nr).dataset.y;
            [x,y]=albers(x,y,plt.labda0,plt.phi0,plt.phi1,plt.phi2);
            handles.datasets(nr).dataset.x=x;
            handles.datasets(nr).dataset.y=y;
    end
    
%     % Convert data to correct coordinate system
%     if ~strcmpi(plt.coordinatesystem.name,'unspecified') && ~strcmpi(data.coordinatesystem.name,'unspecified')
%         if ~strcmpi(plt.coordinatesystem.name,data.coordinatesystem.name) && ...
%                 ~strcmpi(plt.coordinatesystem.type,data.coordinatesystem.type)
%             switch lower(data.type)
%                 case{'2dvector','2dscalar','polyline','grid'}
%                     if ~isfield(handles,'EPSG')
%                         wb = waitbox('Reading coordinate conversion libraries ...');
%                         curdir=[handles.muppetpath 'settings' filesep 'SuperTrans'];
%                         handles.epsg=load([curdir filesep 'data' filesep 'EPSG.mat']);
%                         close(wb);
%                     end
%                     [data.x,data.y]=convertCoordinates(data.x,data.y,handles.epsg,'CS1.name',data.coordinatesystem.name,'CS1.type',data.coordinatesystem.type, ...
%                         'CS2.name',plt.coordinatesystem.name,'CS2.type',data.coordinatesystem.type);
%             end
%         end
%     end
    
    
end

handles=muppet_prepareBar(handles,ifig,j);

muppet_prepareSubplot(handles,ifig,j,leftaxis);

for k=1:nodat    
    handles=muppet_plotDataset(handles,ifig,j,k,'new');
end

switch lower(handles.figures(ifig).figure.subplots(j).subplot.type)
    case {'3d'},
        if handles.figures(ifig).figure.subplots(j).subplot.drawbox
            muppet_set3DBox(handles,ifig,isub);
        end
end

%% Color Bar
if handles.figures(ifig).figure.subplots(j).subplot.plotcolorbar
    handles.figures(ifig).figure.subplots(j).subplot.shadesbar=0;
    for k=1:nodat
        switch lower(handles.figures(ifig).figure.subplots(j).subplot.datasets(k).dataset.plotroutine)
            case{'plotshadesmap','plotpatches'}
                handles.figures(ifig).figure.subplots(j).subplot.shadesbar=1;
        end
    end
    muppet_setColorBar(handles.figures(ifig).figure,ifig,j);
end

if handles.figures(ifig).figure.subplots(j).subplot.plotlegend
    muppet_setLegend(handles.figures(ifig).figure,ifig,j);
end

if handles.figures(ifig).figure.subplots(j).subplot.plotvectorlegend
    muppet_setVectorLegend(handles.figures(ifig).figure,ifig,j);
end

if handles.figures(ifig).figure.subplots(j).subplot.plotnortharrow
    muppet_setNorthArrow(handles.figures(ifig).figure,ifig,j);
end

if handles.figures(ifig).figure.subplots(j).subplot.plotscalebar==1
    muppet_setScaleBar(handles.figures(ifig).figure,ifig,j);
end

set(leftaxis,'Color',colorlist('getrgb','color',handles.figures(ifig).figure.subplots(j).subplot.backgroundcolor));
set(leftaxis,'Tag','axis','UserData',[ifig,j]);


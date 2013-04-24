function h=muppet_plotDataset(handles,ifig,isub,id)

% Plot dataset and returns plot handle (for use in legend)

h=[];

plt=handles.figures(ifig).figure.subplots(isub).subplot;

nr=handles.figures(ifig).figure.subplots(isub).subplot.datasets(id).dataset.number;

data=handles.datasets(nr).dataset;

% Copy plot options to opt structure
opt=plt.datasets(id).dataset;

if handles.figures(ifig).figure.cm2pix==1
    opt2=0;
else
    opt2=1;
end

%% If this is a map plot, try to convert coordinates of datasets if necessary
switch handles.figures(ifig).figure.subplots(isub).subplot.type
    case{'map2d'} 
        % Convert data to correct coordinate system
        if ~strcmpi(plt.coordinatesystem.name,'unspecified') && ~strcmpi(data.coordinatesystem.name,'unspecified')
            if ~strcmpi(plt.coordinatesystem.name,data.coordinatesystem.name) && ...
                    ~strcmpi(plt.coordinatesystem.type,data.coordinatesystem.type)
                switch lower(data.type)
                    case{'2dvector','2dscalar','polyline','grid'}
                        if ~isfield(handles,'EPSG')
                            wb = waitbox('Reading coordinate conversion libraries ...');
                            curdir=[handles.muppetpath 'settings' filesep 'SuperTrans'];
                            handles.epsg=load([curdir filesep 'data' filesep 'EPSG.mat']);
                            close(wb);
                        end
                        [data.x,data.y]=convertCoordinates(data.x,data.y,handles.epsg,'CS1.name',data.coordinatesystem.name,'CS1.type',data.coordinatesystem.type, ...
                            'CS2.name',plt.coordinatesystem.name,'CS2.type',data.coordinatesystem.type);
                end
            end
        end
                
        % Set projection (in case of geographic coordinate systems)
        if strcmpi(handles.figures(ifig).figure.subplots(isub).subplot.coordinatesystem.type,'geographic')
            switch handles.figures(ifig).figure.subplots(isub).subplot.projection
                case{'mercator'}
                    data.y=merc(data.y);
                case{'albers'}
                    x=data.x;
                    y=data.y;
                    [x,y]=albers(x,y,plt.labda0,plt.phi0,plt.phi1,plt.phi2);
                    data.x=x;
                    data.y=y;
            end
        end            
end

% Copy data structure back to handles structure
handles.datasets(nr).dataset=data;
% Copy subplot structure back to handles structure
handles.figures(ifig).figure.subplots(isub).subplot=plt;

%% Plot dataset
switch lower(plt.datasets(id).dataset.plotroutine)
    case {'plottimeseries','plotxy','plotxyseries','plotline','plotspline'}
        h=muppet_plotLine(handles,ifig,isub,id);
    case {'plothistogram'}
        h=muppet_plotHistogram(handles,ifig,isub,id);
    case {'plotstackedarea'}
        h=muppet_plotStackedArea(handles,ifig,isub,id);
    case {'plotcontourmap','plotcontourmaplines','plotpatches','plotcontourlines','plotshadesmap'}
        muppet_plot2DSurface(handles,ifig,isub,id);
    case {'plotgrid'}
        h=muppet_plotGrid(handles,ifig,isub,id);
    case {'plotannotation'},
        h=muppet_plotAnnotation(handles,ifig,isub,id);
%     case {'plotcrosssections'}
%         handles=muppet_plotCrossSections(handles,ifig,isub,id);
    case {'plotsamples'}
        h=muppet_plotSamples(handles,ifig,isub,id);
    case {'plotvectors','plotcoloredvectors'}
        % Colored vectors don't work under 2007b!
        h=muppet_plotVectors(handles,ifig,isub,id);
    case {'plotfeather'}
        h=muppet_plotFeather(handles,ifig,isub,id);
    case {'plotcurvedarrows','plotcoloredcurvedarrows'}
        % Original mex file work under 2007b!
        h=muppet_plotCurVec(handles,ifig,isub,id);
%     case {'plotvectormagnitude'}
%         handles=PlotVectorMagnitude(handles,ifig,isub,id,mode);
    case {'plotpolyline','plotpolygon'}
        h=muppet_plotPolygon(handles,ifig,isub,id);
    case {'plotkub'}
        h=muppet_plotKub(handles,ifig,isub,id);
    case {'plotlint'}
        h=muppet_plotLint(handles,ifig,isub,id);
    case {'plotimage','plotgeoimage'}
        h=muppet_plotImage(handles,ifig,isub,id);
%     case {'plot3dsurface','plot3dsurfacelines'}
%         handles=Plot3DSurface(handles,ifig,isub,id,mode);
%     case {'plotpolygon3d'}
%         handles=PlotPolygon3D(handles,ifig,isub,id,mode);
    case {'plotrose'}
        h=muppet_plotRose(handles,ifig,isub,id);
    case {'plottext'}
        h=muppet_plotText(handles,ifig,isub,id,1);
    case {'plotinteractivepolyline'}
        muppet_plotInteractivePolyline(handles,ifig,isub,id);
    case {'drawspline'}
        DrawSpline(Data,Plt,handles.DefaultColors,opt);
    case {'drawcurvedarrow'}
        DrawCurvedArrow(Data,Ax,Plt,handles.DefaultColors,opt2,1);
    case {'drawcurveddoublearrow'}
        DrawCurvedArrow(Data,Ax,Plt,handles.DefaultColors,opt2,2);
    case{'textbox','rectangle','ellipse','arrow','doublearrow','line'}
        muppet_addAnnotation(handles.figures(ifig).figure,ifig,isub,id);
    case {'plottidalellipse'}
        h=muppet_plotTidalEllipse(handles,ifig,isub,id);
end

%% Add color bar for dataset (in addition to colorbar for subplot!)
clrbar=[];
if opt.plotcolorbar
    opt.shadesbar=0;
    clrbar=muppet_setColorBar(handles.figures(ifig).figure,ifig,isub,id);
end
opt.colorbarhandle=clrbar;

%% Add datestring
if opt.adddatestring
    dstx=0.5*(plt.xmax-plt.xmin)/plt.position(3);
    dsty=0.5*(plt.ymax-plt.ymin)/plt.position(4);
    switch lower(opt.adddate.position),
        case {'lower-left'},
            xpos=plt.xmin+dstx;
            ypos=plt.ymin+dsty;
            horal='left';
        case {'lower-right'},
            xpos=plt.xmax-dstx;
            ypos=plt.ymin+dsty;
            horal='right';
        case {'upper-left'},
            xpos=plt.xmin+dstx;
            ypos=plt.ymax-dsty;
            horal='left';
        case {'upper-right'},
            xpos=plt.xmax-dstx;
            ypos=plt.ymax-dsty;
            horal='right';
    end
    datestring=[opt.adddate.prefix datestr(data.time,opt.adddate.format) opt.adddate.suffix];
    tx=text(xpos,ypos,datestring);
    set(tx,'HorizontalAlignment',horal);
    set(tx,'FontName',opt.adddate.font.name);
    set(tx,'FontSize',opt.adddate.font.size*handles.figures(ifig).figure.fontreduction);
    set(tx,'FontWeight',opt.adddate.font.weight);
    set(tx,'FontAngle',opt.adddate.font.angle);
    set(tx,'Color',colorlist('getrgb','color',opt.adddate.font.color));
end


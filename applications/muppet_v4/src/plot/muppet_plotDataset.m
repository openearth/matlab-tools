function handles=muppet_plotDataset(handles,ifig,isub,id,mode)

plt=handles.figures(ifig).figure.subplots(isub).subplot;

if ~isfield(plt.datasets(id).dataset,'number')
    plt.datasets(id).dataset.number=[];
end

nr=plt.datasets(id).dataset.number;
if ~isempty(nr)
    data=handles.datasets(nr).dataset;
end

opt=plt.datasets(id).dataset;

if handles.figures(ifig).figure.cm2pix==1
    opt2=0;
else
    opt2=1;
end

handles.figures(ifig).figure.subplots(isub).subplot.datasets(id).dataset.handle=[];

switch lower(plt.datasets(id).dataset.plotroutine)
    case {'plottimeseries','plotxy','plotxyseries','plotline','plotspline'}
        handles=muppet_plotLine(handles,ifig,isub,id);
    case {'plothistogram'}
        handles=PlotHistogram(handles,ifig,isub,id,mode);
    case {'plotstackedarea'}
        handles=PlotStackedArea(handles,ifig,isub,id,mode);
    case {'plotcontourmap','plotcontourmaplines','plotpatches','plotcontourlines','plotshadesmap'}
%         handles=Plot2DSurface(handles,ifig,isub,id,mode);
        muppet_plot2DSurface(handles,ifig,isub,id);
    case {'plotgrid'}
%        handles=PlotGrid(handles,ifig,isub,id,mode);
        handles=muppet_plotGrid(handles,ifig,isub,id);
    case {'plotannotation'},
        handles=PlotAnnotation(handles,ifig,isub,id,mode);
    case {'plotcrosssections'}
        handles=PlotCrossSections(handles,ifig,isub,id,mode);
    case {'plotsamples'}
        handles=PlotSamples(handles,ifig,isub,id,mode);
    case {'plotvectors','plotcoloredvectors'}
        % Colored vectors don't work under 2007b!
        handles=muppet_plotVectors(handles,ifig,isub,id);
    case {'plotfeather'}
        handles=muppet_plotFeather(handles,ifig,isub,id);
    case {'plotcurvedarrows','plotcoloredcurvedarrows'}
        % Original mex file work under 2007b!
        handles=muppet_plotCurVec(handles,ifig,isub,id);
    case {'plotvectormagnitude'}
        handles=PlotVectorMagnitude(handles,ifig,isub,id,mode);
    case {'plotpolyline','plotpolygon'}
        handles=muppet_plotPolygon(handles,ifig,isub,id);
    case {'plotkub'}
        handles=PlotKub(handles,ifig,isub,id,mode);
    case {'plotlint'}
        handles=PlotLint(handles,ifig,isub,id,mode);
    case {'plotimage','plotgeoimage'}
        handles=PlotImage(handles,ifig,isub,id,mode);
    case {'plot3dsurface','plot3dsurfacelines'}
        handles=Plot3DSurface(handles,ifig,isub,id,mode);
    case {'plotpolygon3d'}
        handles=PlotPolygon3D(handles,ifig,isub,id,mode);
    case {'plotrose'}
        handles=PlotRose(handles,ifig,isub,id,mode);
    case {'plottext'}
        handles=muppet_plotText(handles,ifig,isub,id,1);
    case {'drawpolyline'}
        DrawPolyline(Data,Plt,handles.DefaultColors,opt);
    case {'drawspline'}
        DrawSpline(Data,Plt,handles.DefaultColors,opt);
    case {'drawcurvedarrow'}
        DrawCurvedArrow(Data,Ax,Plt,handles.DefaultColors,opt2,1);
    case {'drawcurveddoublearrow'}
        DrawCurvedArrow(Data,Ax,Plt,handles.DefaultColors,opt2,2);
    case{'textbox','rectangle','ellipse','arrow','doublearrow','line'}
        muppet_addAnnotation(handles.figures(ifig).figure,ifig,isub,id);
    case {'plottidalellipse'}
        handles=muppet_plotTidalEllipse(handles,ifig,isub,id);
end

clrbar=[];
if opt.plotcolorbar
    opt.shadesbar=0;
    clrbar=muppet_setColorBar(handles.figures(ifig).figure,ifig,isub,id);
end
opt.colorbarhandle=clrbar;

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


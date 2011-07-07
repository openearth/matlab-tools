function handles=setMapAxisProperties(handles,Model,t,wdt,hgt,tit,barlabl,clim,clmap,nd,opt)

handles=InitializeAxisProperties(handles,1);

handles.Figure.Axis(1).Nr=nd;


if strcmpi(opt,'gmap')

%     if ~strcmpi(Model.CoordinateSystemType,'geographic')
%         [Model.XLimPlot(1),Model.YLimPlot(1)]=ConverCoordinates(Model.XLimPlot(1),Model.YLimPlot(1),Model.CoordinateSystem,Model.CoordinateSystemType,'WGS 84','geographic',hm.CoordinateSystems,hm.Operations);
%         [Model.XLimPlot(2),Model.YLimPlot(2)]=ConverCoordinates(Model.XLimPlot(2),Model.YLimPlot(2),Model.CoordinateSystem,Model.CoordinateSystemType,'WGS 84','geographic',hm.CoordinateSystems,hm.Operations);
%     end

    handles.Figure.Axis(1).DrawBox=0;
    handles.Figure.Axis(1).Position(1)=0.1;
    handles.Figure.Axis(1).Position(2)=0.1;
    handles.Figure.Axis(1).Position(1)=0.0;
    handles.Figure.Axis(1).Position(2)=0.0;
    handles.Figure.Axis(1).Position(3)=wdt;
    handles.Figure.Axis(1).Position(4)=hgt;
    handles.Figure.Axis(1).PlotType='2d';
    handles.Figure.Axis(1).BackgroundColor='none';

    handles.Figure.Axis(1).XMin=Model.XLimPlot(1);
    handles.Figure.Axis(1).XMax=Model.XLimPlot(2);
    handles.Figure.Axis(1).YMin=Model.YLimPlot(1);
    handles.Figure.Axis(1).YMax=Model.YLimPlot(2);

    handles.Figure.Axis(1).ColMap=clmap;

    handles.Figure.Axis(1).CMin=clim(1);
    handles.Figure.Axis(1).CStep=clim(2);
    handles.Figure.Axis(1).CMax=clim(3);

else

    handles.Figure.Axis(1).DrawBox=1;
    handles.Figure.Axis(1).Position(1)=1;
    handles.Figure.Axis(1).Position(2)=1;
    handles.Figure.Axis(1).Position(3)=wdt;
    handles.Figure.Axis(1).Position(4)=hgt;
    handles.Figure.Axis(1).PlotType='2d';
    handles.Figure.Axis(1).BackgroundColor='white';

    handles.Figure.Axis(1).XMin=Model.XLimPlot(1);
    handles.Figure.Axis(1).XMax=Model.XLimPlot(2);
    handles.Figure.Axis(1).XTick=Model.XTick;
    if Model.XTick>=1
        decx=0;
    else
        decx=1;
    end
    handles.Figure.Axis(1).DecimX=1;
    handles.Figure.Axis(1).YMin=Model.YLimPlot(1);
    handles.Figure.Axis(1).YMax=Model.YLimPlot(2);
    if Model.YTick>=1
        decy=0;
    else
        decy=1;
    end
    handles.Figure.Axis(1).YTick=Model.YTick;
    handles.Figure.Axis(1).DecimY=decy;
    handles.Figure.Axis(1).Title=[tit ' - ' datestr(t,0) ' (UTC)'];
    handles.Figure.Axis(1).XLabel='longitude (\circ)';
    handles.Figure.Axis(1).YLabel='latitude ( \circ)';

    handles.Figure.Axis(1).PlotColorBar=1;
    handles.Figure.Axis(1).ColorBarPosition=[12 1 0.5 hgt];
    handles.Figure.Axis(1).ColorBarLabel=barlabl;
    handles.Figure.Axis(1).ColMap=clmap;

    handles.Figure.Axis(1).CMin=clim(1);
    handles.Figure.Axis(1).CStep=clim(2);
    handles.Figure.Axis(1).CMax=clim(3);

    handles.Figure.Axis(1).AxesFontSize=6;
    handles.Figure.Axis(1).ColorBarFontSize=6;
    handles.Figure.Axis(1).TitleFontSize=7;
    handles.Figure.Axis(1).XLabelFontSize=6;
    handles.Figure.Axis(1).YLabelFontSize=6;

end


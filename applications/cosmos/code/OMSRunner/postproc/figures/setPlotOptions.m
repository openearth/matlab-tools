function handles=setPlotOptions(handles,Model,nd,clim,im)

for id=1:nd
    handles=InitializePlotProperties(handles,1,id);
    handles.Figure.Axis(1).Plot(id).Name=handles.DataProperties(id).Name;
    

    switch lower(handles.DataProperties(id).Type)
        case{'2dscalar'}
            handles.Figure.Axis(1).Plot(id).PlotRoutine='PlotPatches';
%            handles.Figure.Axis(1).Plot(id).PlotRoutine='PlotContourMap';
%            handles.Figure.Axis(1).Plot(id).PlotRoutine='PlotShadesMap';
        case{'2dvector'}
            handles.Figure.Axis(1).Plot(id).PlotRoutine='PlotVectors';
%             handles.Figure.Axis(1).Plot(id).FieldThinningType='Uniform';
%             handles.Figure.Axis(1).Plot(id).FieldThinningFactor1=3;
            handles.Figure.Axis(1).Plot(id).DDtCurVec=Model.mapPlots(im).dtAnim;
            
%            if strcmpi(Model.CoordinateSystemType,'geographic')
                Model.mapPlots(im).Dataset(nd).DtCurVec=Model.mapPlots(im).Dataset(nd).DtCurVec/100000;
%            end
            
            if ~strcmpi(Model.CoordinateSystemType,'geographic')
                Model.mapPlots(im).Dataset(nd).DxCurVec=Model.mapPlots(im).Dataset(nd).DxCurVec/100000;
            end
            Model.mapPlots(im).Dataset(nd).RelSpeedCurVec=Model.mapPlots(im).Dataset(nd).DtCurVec/(3*handles.Figure.Axis(1).Plot(id).DDtCurVec);
            
            handles.Figure.Axis(1).Plot(id).PlotRoutine=Model.mapPlots(im).Dataset(nd).PlotRoutine;
            handles.Figure.Axis(1).Plot(id).CMin   =clim(1);
            handles.Figure.Axis(1).Plot(id).CStep   =clim(2);
            handles.Figure.Axis(1).Plot(id).CMax   =clim(3);
            handles.Figure.Axis(1).Plot(id).ColorMap = Model.mapPlots(im).ColorMap;
%            handles.Figure.Axis(1).Plot(id).LineColor= Model.mapPlots(im).Dataset(nd).LineColor;
            handles.Figure.Axis(1).Plot(id).LineColor= 'none';
            handles.Figure.Axis(1).Plot(id).DxCurVec=  Model.mapPlots(im).Dataset(nd).DxCurVec ;
            handles.Figure.Axis(1).Plot(id).DtCurVec = Model.mapPlots(im).Dataset(nd).DtCurVec;
            handles.Figure.Axis(1).Plot(id).RelSpeedCurVec = Model.mapPlots(im).Dataset(nd).RelSpeedCurVec;
            handles.Figure.Axis(1).Plot(id).HeadThickness=  3 ;
            handles.Figure.Axis(1).Plot(id).ArrowThickness =  1 ;
            
        case{'polyline'}
            handles.Figure.Axis(1).Plot(id).PlotRoutine='PlotPolygon';
            handles.Figure.Axis(1).Plot(id).FillPolygons=1;
            handles.Figure.Axis(1).Plot(id).FillColor='lightgreen';
    end
end

%     nd=nd+1;
%     handles=InitializePlotProperties(handles,1,nd);
%     handles.Figure.Axis(1).Plot(nd).Name='hs vector';
%     handles.Figure.Axis(1).Plot(nd).PlotRoutine='PlotVectors';
%     handles.Figure.Axis(1).Plot(nd).UnitVector=0.05;
%     handles.Figure.Axis(1).Plot(nd).FieldThinningType='Uniform';
%     handles.Figure.Axis(1).Plot(nd).FieldThinningFactor1=3;
%     handles.Figure.Axis(1).Plot(nd).FieldThinningFactor2=3;

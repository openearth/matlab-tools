function handles=ReadDefaults(handles)

%d3dpath=[getenv('D3D_HOME') '\' getenv('ARCH') '\'];

d3dpath=[handles.MuppetDir 'muppet\'];

handles.DefaultFigureProperties=[];

txt=ReadTextFile([d3dpath 'settings\defaults\figureproperties.def']);
for i=1:length(txt)
    if i==1
        k=1;
    else
        k=0;
    end
    handles=ReadFigureProperties(handles,txt,i,1,k,1,1.0);
end
handles.DefaultFigureProperties.NrAnnotations=0;
handles.DefaultFigureProperties.FileName='';
handles.DefaultFigureProperties.Format='png';
handles.DefaultFigureProperties.Resolution=300;
handles.DefaultFigureProperties.Renderer='zbuffer';

handles.DefaultAnnotationOptions=[];
txt=ReadTextFile([d3dpath 'settings\defaults\annotations.def']);
for i=1:length(txt)
    if i==1
        k=1;
    else
        k=0;
    end
    handles=ReadAnnotationOptions(handles,txt,i,1,1,k,1);
end

txt=ReadTextFile([d3dpath 'settings\defaults\subplotproperties.def']);
for i=1:length(txt)
    if i==1
        k=1;
    else
        k=0;
    end
    handles=ReadSubplotProperties(handles,txt,i,1,1,k,1);
end
handles.DefaultSubplotProperties.PlotNorthArrow=0;
handles.DefaultSubplotProperties.PlotScaleBar=0;
handles.DefaultSubplotProperties.PlotLegend=0;
handles.DefaultSubplotProperties.PlotVectorLegend=0;
handles.DefaultSubplotProperties.PlotColorBar=0;

txt=ReadTextFile([d3dpath 'settings\defaults\plotoptions.def']);
for i=1:length(txt)
    if i==1
        k=1;
    else
        k=0;
    end
    handles=ReadPlotOptions(handles,txt,i,1,1,1,k,1);
end

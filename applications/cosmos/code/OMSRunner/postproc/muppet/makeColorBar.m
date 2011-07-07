function makeColorBar(handles,dr,name,clim,clmap,barlabel)

handles.NrAvailableDatasets=0;
handles.Figure=handles.DefaultFigureProperties;
handles=InitializeAxisProperties(handles,1);

handles.Figure.FileName=[dr 'lastrun' filesep 'figures' filesep name '.colorbar.png'];

handles.Figure.PaperSize=[1.7 5.5];
handles.Figure.BackgroundColor='none';
handles.Figure.Frame='none';

handles.Figure.Format='png';
handles.Figure.Resolution=150;
handles.Figure.Renderer='zbuffer';
handles.Figure.Orientation='p';
handles.Figure.NrAnnotations=0;

handles.Figure.NrSubplots=1;

handles.Figure.Axis(1).Nr=0;

handles.Figure.Axis(1).DrawBox=0;
handles.Figure.Axis(1).Position(1)=-10;
handles.Figure.Axis(1).Position(2)=-10;
handles.Figure.Axis(1).Position(3)=1;
handles.Figure.Axis(1).Position(4)=1;
handles.Figure.Axis(1).PlotType='2d';
handles.Figure.Axis(1).BackgroundColor='none';

handles.Figure.Axis(1).XMin=0;
handles.Figure.Axis(1).XMax=1;
handles.Figure.Axis(1).YMin=0;
handles.Figure.Axis(1).YMax=1;

handles.Figure.Axis(1).PlotColorBar=1;
handles.Figure.Axis(1).ColorBarPosition=[0.7 0.2 0.25 5];
handles.Figure.Axis(1).ColorBarLabel=barlabel;
handles.Figure.Axis(1).ColMap=clmap;
handles.Figure.Axis(1).ColorBarFontColor='yellow';

handles.Figure.Axis(1).CMin=clim(1);
handles.Figure.Axis(1).CStep=clim(2);
handles.Figure.Axis(1).CMax=clim(3);

handles.Figure.Axis(1).Plot=[];

% Make figure
makeMuppetFigure(handles);

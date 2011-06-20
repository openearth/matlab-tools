function handles=setFigureProperties(handles,wdt,hgt,figname,opt)

handles.Figure=handles.DefaultFigureProperties;

handles.Figure.Name='figure1';

if strcmpi(opt,'gmap')
%    handles.Figure.PaperSize=[wdt+0.1 hgt+0.1];
    handles.Figure.PaperSize=[wdt hgt];
    handles.Figure.BackgroundColor='white';
else   
    handles.Figure.PaperSize=[wdt+3.5 hgt+1.5];
    handles.Figure.BackgroundColor='white';
end
handles.Figure.Frame='none';

handles.Figure.FileName=figname;
handles.Figure.Format='png';
handles.Figure.Resolution=150;
handles.Figure.Renderer='zbuffer';
handles.Figure.Orientation='p';
handles.Figure.NrAnnotations=0;
handles.Figure.BackgroundColor='none';

handles.Figure.NrSubplots=1;

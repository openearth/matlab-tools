function muppet_preview

handles=getHandles;

%if handles.mode==1
wb = waitbox('Preparing figure...');
try
    handles=muppet_makeFigure(handles,handles.activefigure,'preview');
    setHandles(handles);
%     fig=handles.figures(handles.activefigure).figure;
%     fig.number=handles.activefigure;
%     fig.changed=0;
%     fig.annotationschanged=0;
%     setappdata(fig.handle,'figure',fig);
    set(gcf,'Visible','on');
catch
    h=findobj('Tag','waitbox');
    close(h);
    err=lasterror;
    str{1}=['An error occured in function: '  err.stack(1).name];
    str{2}=['Error: '  err.message];
    str{3}=['File: ' err.stack(1).file];
    str{4}=['Line: ' num2str(err.stack(1).line)];
    str{5}=['See muppet.err for more information'];
    strv=strvcat(str{1},str{2},str{3},str{4},str{5});
    uiwait(errordlg(strv,'Error','modal'));
    muppet_writeErrorLog(err);
end
if ishandle(wb)
    close(wb);
end

delete('curvecpos.*.dat');
muppet_setPlotEdit(0);

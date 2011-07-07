function makeMuppetFigure(handles)

mpt=figure('Visible','off','Position',[0 0 0.2 0.2]);
set(mpt,'Name','Muppet','NumberTitle','off');
guidata(mpt,handles);
ExportFigure(handles,1,'export');
close(mpt);

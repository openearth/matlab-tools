function ddb_aboutDelftDashBoard(handles)

MakeNewWindow('About Delft Dashboard',[400 400],'modal',[handles.settingsDir '\icons\deltares.gif']);
set(gcf,'Resize','off');
ax=axes;
set(ax,'Units','pixels');
set(ax,'Position',[0 0 400 400]);

StatName=[handles.settingsDir '\icons\delftdashboard.jpg'];
c = imread(StatName,'jpeg');
image(c);
tick(gca,'x','none');tick(gca,'y','none');%axis equal;

font='Arial';
col=[143 188 143]/255;

tx=text(235,377,['Version ' handles.delftDashBoardVersion]);
try
    set(tx,'FontSize',12,'Color',[0 0 0],'HorizontalAlignment','left','FontName',font);
catch
    set(tx,'FontSize',12,'Color',col,'HorizontalAlignment','left','FontName','Times New Roman');
end

tx2=text(11,299,'Contact Maarten van Ormondt for more information');
tx=text(10,300,'Contact Maarten van Ormondt for more information');
col='r';
try
    set(tx,'FontSize',12,'Color','y','HorizontalAlignment','left','FontName',font,'FontWeight','bold');
    set(tx2,'FontSize',12,'Color','g','HorizontalAlignment','left','FontName',font,'FontWeight','bold');
catch
    set(tx,'FontSize',12,'Color',col,'HorizontalAlignment','left','FontName','Times New Roman','FontWeight','bold');
end
tx2=text(11,319,'Maarten.vanOrmondt@deltares.nl');
tx=text(10,320,'Maarten.vanOrmondt@deltares.nl');
try
    set(tx,'FontSize',12,'Color','y','HorizontalAlignment','left','FontName',font,'FontWeight','bold');
    set(tx2,'FontSize',12,'Color','g','HorizontalAlignment','left','FontName',font,'FontWeight','bold');
catch
    set(tx,'FontSize',10,'Color',col,'HorizontalAlignment','left','FontName','Times New Roman','FontWeight','bold');
end

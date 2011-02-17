function ddb_updateCoordinateText(pnt,dummy)

handles=getHandles;
ax=handles.GUIHandles.mapAxis;

pos = get(ax, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);
xlim=get(ax,'xlim');
ylim=get(ax,'ylim');

if posx<=xlim(1) || posx>=xlim(2) || posy<=ylim(1) || posy>=ylim(2)
    strx='X : ';
    stry='Y : ';
    set(gcf,'Pointer','arrow');
else
    strx=['X : ' num2str(posx,'%10.2f')];
    stry=['Y : ' num2str(posy,'%10.2f')];
    setptr(gcf,pnt);
end

set(handles.GUIHandles.textXCoordinate,'String',strx);
set(handles.GUIHandles.textYCoordinate,'String',stry);
% set(gca,'FontSize',8);
% grid on;

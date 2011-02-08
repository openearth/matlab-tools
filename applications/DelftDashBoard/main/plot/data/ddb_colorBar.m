function ddb_colorBar(opt,varargin)

handles=getHandles;

switch lower(opt)
    case{'make'}
        mapPanel=handles.GUIHandles.mapPanel;
        ppos=get(mapPanel,'Position');
        pos(1)=ppos(3)-40;
        pos(2)=10;
        pos(3)=20;
        pos(4)=ppos(4)-50;
        handles.GUIHandles.colorBarPanel=uipanel('Units','pixels','Parent',mapPanel,'Position',[70 200 870 440]);
        set(handles.GUIHandles.colorBarPanel,'BorderType','beveledout','BorderWidth',1,'BackgroundColor','none');
        set(handles.GUIHandles.colorBarPanel,'Position',pos);
        clrbar=axes;
        set(clrbar,'Units','pixels');
        set(clrbar,'Parent',handles.GUIHandles.colorBarPanel);
        pos(1)=1;
        pos(2)=1;
        pos(3)=pos(3);
        pos(4)=pos(4);
        set(clrbar,'Position',pos);
        set(clrbar,'xlim',[0 1],'ylim',[0 1]);
        set(clrbar,'XTick',[]);
        set(clrbar,'HitTest','off');
        set(clrbar,'Tag','colorbar');
        set(clrbar,'Box','off');
        set(clrbar,'TickLength',[0 0]);
        handles.GUIHandles.colorBar=clrbar;
        setHandles(handles);
    case{'update'}
        set(handles.GUIHandles.MainWindow,'CurrentAxes',handles.GUIHandles.colorBar);
%        axes(handles.GUIHandles.colorBar);
        cla;
        colormap=varargin{1};
        clim=get(handles.GUIHandles.mapAxis,'CLim');
        nocol=64;
        clmap=ddb_getColors(colormap,nocol)*255;
        x(1)=0;x(2)=1;x(3)=1;x(4)=0;x(5)=0;
        for i=1:nocol
            col=clmap(i,:);
            y(1)=clim(1)+(clim(2)-clim(1))*(i-1)/nocol;
            y(2)=y(1);
            y(3)=clim(1)+(clim(2)-clim(1))*(i)/nocol;
            y(4)=y(3);
            y(5)=y(1);
            fl=fill(x,y,'b');hold on;
            set(fl,'FaceColor',col,'LineStyle','none');
        end
        set(handles.GUIHandles.colorBar,'XTick',[]);
        set(handles.GUIHandles.colorBar,'xlim',[0 1],'ylim',[clim(1) clim(2)]);
        set(handles.GUIHandles.colorBar,'Box','off');
        set(handles.GUIHandles.colorBar,'TickLength',[0 0]);
    case{'resize'}
        mapPanel=handles.GUIHandles.mapPanel;
        ppos=get(mapPanel,'Position');
        pos(1)=ppos(3)-40;
        pos(2)=10;
        pos(3)=20;
        pos(4)=ppos(4)-50;
        set(handles.GUIHandles.colorBar,'Position',pos);
end
set(handles.GUIHandles.MainWindow,'CurrentAxes',handles.GUIHandles.mapAxis);


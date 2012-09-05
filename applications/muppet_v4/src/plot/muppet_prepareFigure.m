function handles=muppet_prepareFigure(handles,ifig,mode)

fig=handles.figures(ifig).figure;

if strcmp(mode,'preview')
    fig.units='pixels';
    a=get(0,'ScreenSize');
    asprat=fig.width/fig.height;
    if asprat<a(3)/a(4)
        y1=0.88*a(4);
        fig.cm2pix=y1/fig.height;
    else
        x1=0.88*a(3);
        fig.cm2pix=x1/fig.width;
    end
    ScreenPixelsPerInch=get(0,'ScreenPixelsPerInch');
    cm2pix=fig.cm2pix;
    fig.fontreduction=2.5*cm2pix/ScreenPixelsPerInch;
else
    fig.units='centimeters';
    fig.cm2pix=1;
    fig.fontreduction=1;
end

paperwidth=fig.width*fig.cm2pix;
paperheight=fig.height*fig.cm2pix;
BackgroundColor=colorlist('getrgb','color',fig.backgroundcolor);

if strcmp(mode,'export') || strcmp(mode,'guiexport')
    % Exporting figure
    figh=figure(999);
    set(figh,'visible','off');
    set(figh,'PaperUnits',fig.units);
    if strcmp(fig.orientation,'landscape')
        set(figh,'PaperSize',[paperheight paperwidth]);
    else
        set(figh,'PaperSize',[paperwidth paperheight]);
    end         
    set(figh,'PaperPosition',[0.0 0.0 paperwidth paperheight]);
    set(figh,'Renderer',fig.renderer);
    set(figh,'Tag','figure','UserData',ifig);
    for k=1:fig.nrsubplots
        if strcmpi(fig.subplots(k).subplot.type,'3d') && fig.subplots(k).subplot.drawbox
            BackgroundColor=colorlist('getrgb','color',fig.subplots(k).subplot.backgroundcolor);
        end
    end
else
    % Previewing figure
    hf=findobj('Tag','figure','UserData',ifig);
    if ~isempty(hf)
        OldPosition=get(figure(ifig),'Position');
    else
        OldPosition=[0 0 0 0];
    end
    figh=figure;
    set(figh,'Tag','figure','UserData',ifig);
    clf;

    try
        fh = get(gcf,'JavaFrame'); % Get Java Frame
        fh.setFigureIcon(javax.swing.ImageIcon([handles.muppetpath 'settings' filesep 'icons' filesep 'deltares.gif']));
    end

    fig.zoom='none';
    set(figh,'menubar','none');
    tbh=uitoolbar(gcf);

    icons=load([handles.muppetpath 'settings' filesep 'icons' filesep 'ico.mat']);
    c=icons.icon;

    h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom In');
    set(h,'ClickedCallback',{@muppet_zoomInOutPan,1});
    set(h,'Tag','UIToggleToolZoomIn');
    set(h,'cdata',c.zoomin16);

    h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Zoom Out');
    set(h,'ClickedCallback',{@muppet_zoomInOutPan,2});
    set(h,'Tag','UIToggleToolZoomOut');
    set(h,'cdata',c.zoomout16);

    h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Pan');
    set(h,'ClickedCallback',{@muppet_zoomInOutPan,3}');
    set(h,'Tag','UIToggleToolPan');
    set(h,'cdata',c.pan);

    h = uitoggletool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Rotate 3D');
    set(h,'ClickedCallback',{@muppet_zoomInOutPan,4}');
    set(h,'Tag','UIToggleToolPan');
    set(h,'cdata',c.rotate3d);

    edi = uitoggletool(tbh,'Separator','on','HandleVisibility','on','ToolTipString','Edit Figure');
    set(edi,'ClickedCallback',{@muppet_UIEditFigure});
    set(edi,'Tag','UIToggleToolEditFigure');
    set(edi,'cdata',c.pointer);

    adj = uipushtool(tbh,'Separator','on','HandleVisibility','on','ToolTipString','Keep New Layout');
    set(adj,'ClickedCallback',{@muppet_fixAxes});
    set(adj,'Tag','UIPushToolAdjustAxes');
    set(adj,'cdata',c.properties_doc16);

    red = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Redraw');
    set(red,'ClickedCallback',{@muppet_UIRedraw});
    set(red,'Tag','UIPushToolRedraw');
    set(red,'cdata',c.refresh_doc16);

%     xpor = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Export Figure');
%     set(xpor,'ClickedCallback',{@muppet_UIExport});
%     set(xpor,'Tag','UIPushToolExport');
%     set(xpor,'cdata',c.save_green16);

    addsubplot = uipushtool(tbh,'Separator','on','HandleVisibility','on','ToolTipString','Add Subplot');
    set(addsubplot,'ClickedCallback',{@muppet_UIAddSubplot});
    set(addsubplot,'Tag','UIPushToolAddSubplot');
    set(addsubplot,'cdata',c.graph_bar16);

    addtextbox = uipushtool(tbh,'Separator','on','HandleVisibility','on','ToolTipString','Add Textbox');
    set(addtextbox,'ClickedCallback',{@muppet_UIAddTextBox});
    set(addtextbox,'Tag','UIPushToolAddTextBox');
    set(addtextbox,'cdata',c.tool_text);

    addline = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Add Line');
    set(addline,'ClickedCallback',{@muppet_UIAddLine});
    set(addline,'Tag','UIPushToolAddLine');
    set(addline,'cdata',c.tool_line);

    addarrow = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Add Arrow');
    set(addarrow,'ClickedCallback',{@muppet_UIAddArrow});
    set(addarrow,'Tag','UIPushToolAddArrow');
    set(addarrow,'cdata',c.tool_arrow);

    adddoublearrow = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Add Double Arrow');
    set(adddoublearrow,'ClickedCallback',{@muppet_UIAddDoubleArrow});
    set(adddoublearrow,'Tag','UIPushToolAddDoubleArrow');
    set(adddoublearrow,'cdata',c.tool_double_arrow);

    addrectangle = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Add Rectangle');
    set(addrectangle,'ClickedCallback',{@muppet_UIAddRectangle});
    set(addrectangle,'Tag','UIPushToolAddRectangle');
    set(addrectangle,'cdata',c.tool_rectangle);

    addellipse = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Add Ellipse');
    set(addellipse,'ClickedCallback',{@muppet_UIAddEllipse});
    set(addellipse,'Tag','UIPushToolAddEllipse');
    set(addellipse,'cdata',c.tool_ellipse);

    h = uipushtool(tbh,'Separator','on','HandleVisibility','on','ToolTipString','Draw Polyline');
    set(h,'ClickedCallback',{@muppet_UIDrawFreeHand,1});
    set(h,'Tag','UIPushToolDrawPolyline');
    cda=single(MakeIcon([handles.muppetpath 'settings' filesep 'icons' filesep 'polyline.bmp'],18,0.99));
    set(h,'cdata',cda);

    h = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Draw Spline');
    set(h,'ClickedCallback',{@muppet_UIDrawFreeHand,2});
    set(h,'Tag','UIPushToolSpline');
    cda=single(MakeIcon([handles.muppetpath 'settings' filesep 'icons' filesep 'spline.bmp'],18,0.99));
    set(h,'cdata',cda);

    h = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Draw Curved Arrow');
    set(h,'ClickedCallback',{@muppet_UIDrawFreeHand,3});
    set(h,'Tag','UIPushToolDrawCurvedVector');
    cda=single(MakeIcon([handles.muppetpath 'settings' filesep 'icons' filesep 'curvec2.bmp'],18,0.99));
    set(h,'cdata',cda);

    h = uipushtool(tbh,'Separator','off','HandleVisibility','on','ToolTipString','Add Text');
    set(h,'ClickedCallback',{@muppet_UIAddText});
    set(h,'Tag','UIPushToolAddText');
    set(h,'cdata',c.tool_text);

    a=get(0,'ScreenSize');
    NewPosition=[round(a(3)/2)-0.5*paperwidth round(a(4)/2)-0.5*paperheight-10 paperwidth paperheight];
    if abs(OldPosition(3)-NewPosition(3))>2 || abs(OldPosition(4)-NewPosition(4))>2 
        set(figh,'Position',NewPosition);
    end
    
    set(figh,'Renderer',fig.renderer);
    set(figh,'Name',[fig.name],'NumberTitle','off');
    set(figh,'Resize','off');
    set(figh,'ButtonDownFcn',[]);

    set(figh,'CloseRequestFcn',{@muppet_closeFigure});

    plotedit off;

end

set(figh,'Color',BackgroundColor);
set(figh, 'InvertHardcopy', 'off');
set(figh,'Tag','figure','UserData',ifig);
fig.handle=figh;
set(figh,'Visible','off');

handles.figures(ifig).figure=fig;

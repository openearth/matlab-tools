function changed=muppet_checkForChanges(handles)

changed=0;

fig=getappdata(gcf,'figure');
if fig.changed
    changed=1;
    return
end

return

if handles.figures(ifig).figure.nrannotations>0
    nrsub=handles.figures(ifig).figure.nrsubplots-1;
else
    nrsub=handles.figures(ifig).figure.nrsubplots;
end

%% Check for deleted subplots
h=findobj(gcf,'Tag','axis');
if length(h)~=nrsub
    changed=1;
    disp(['Number of subplots has changed from ' num2str(nrsub) ' to ' num2str(length(h))]);
    return
end

%% Check for position changes in subplots
for i=1:nrsub
    if ~strcmpi(handles.figures(ifig).figure.subplots(i).subplot.type,'image') && ~strcmpi(handles.figures(ifig).figure.subplots(i).subplot.type,'rose')
        pos0=handles.figures(ifig).figure.subplots(i).subplot.position;
        ax=findobj(gcf,'Tag','axis','UserData',[ifig,i]);
        posn=get(ax,'Position')/handles.figures(ifig).figure.cm2pix;
        pos0=round(100*pos0)/100;
        posn=round(100*posn)/100;
        if min(posn==pos0)==0
            changed=1;
            disp(['Position of subplot ' num2str(i) ' has changed from ' num2str(pos0) ' to ' num2str(posn) ]);
            return
        end
    end
end

%% Check for changes in axes limits
for i=1:nrsub
    ax=findobj(gcf,'Tag','axis','UserData',[ifig,i]);
    xlim0=[handles.figures(ifig).figure.subplots(i).subplot.XMin handles.figures(ifig).figure.subplots(i).subplot.XMax];
    ylim0=[handles.figures(ifig).figure.subplots(i).subplot.YMin handles.figures(ifig).figure.subplots(i).subplot.YMax];
    xlimn=get(ax,'XLim');
    ylimn=get(ax,'YLim');
    dif(1)=abs(ylim0(1)-ylimn(1))/abs(ylim0(2)-ylim0(1));
    dif(2)=abs(ylim0(2)-ylimn(2))/abs(ylim0(2)-ylim0(1));
    if ~strcmpi(handles.figures(ifig).figure.subplots(i).subplot.PlotType,'timeseries')
        dif(3)=abs(xlim0(1)-xlimn(1))/abs(xlim0(2)-xlim0(1));
        dif(4)=abs(xlim0(2)-xlimn(2))/abs(xlim0(2)-xlim0(1));
    end
    if max(dif)>0.01
        disp(['Axis limits of subplot ' num2str(i) ' have changed']);
        changed=1;
        return
    end
end

% Check for changes in color bar
for i=1:nrsub
    if handles.figures(ifig).figure.subplots(i).subplot.PlotColorBar
        h=findobj(gcf,'Tag','colorbar','UserData',[ifig,i]);
        if ~isempty(h)
            pos0=handles.figures(ifig).figure.subplots(i).subplot.ColorBarPosition;
            posn=get(h,'Position')/handles.figures(ifig).figure.cm2pix;
            pos0=round(100*pos0)/100;
            posn=round(100*posn)/100;
            if min(posn==pos0)==0
                changed=1;
                disp(['Position of colorbar ' num2str(i) ' has changed from ' num2str(pos0) ' to ' num2str(posn) ]);
                return
            end           
        else
            disp(['Colorbar subplot ' num2str(i) ' not found']);
            changed=1;
            return
        end
    end
    for k=1:handles.figures(ifig).figure.subplots(i).subplot.Nr
        if handles.figures(ifig).figure.subplots(i).subplot.Plot(k).PlotColorBar
            h=findobj(gcf,'Tag','colorbar','UserData',[ifig,i,k]);
            if ~isempty(h)
                pos0=handles.figures(ifig).figure.subplots(i).subplot.Plot(k).ColorBarPosition;
                posn=get(h,'Position')/handles.figures(ifig).figure.cm2pix;
                pos0=round(100*pos0)/100;
                posn=round(100*posn)/100;
                if min(posn==pos0)==0
                    changed=1;
                    disp(['Position of secondary colorbar ' num2str(i) ',' num2str(k) ' has changed from ' num2str(pos0) ' to ' num2str(posn) ]);
                    return
                end
            else
                disp(['Secondary colorbar subplot '  num2str(i) ',' num2str(k)  ' not found']);
                changed=1;
                return
            end
        end
    end
end

% Check for changes in legend
for i=1:nrsub
    if handles.figures(ifig).figure.subplots(i).subplot.PlotLegend
        hh=findobj(gcf,'Tag','legend');
        for ii=1:length(hh)
            d=getappdata(hh(ii));
            if d.LegendData.i==ifig && d.LegendData.j==i
                h=hh(ii);
            end
        end
        pos0=handles.figures(ifig).figure.subplots(i).subplot.LegendPosition;
        locn=get(h,'Location');
        posn=get(h,'Position')/handles.figures(ifig).figure.cm2pix;
        if strcmp(locn,'none')
            if ischar(pos0)
                changed=1;
                disp(['Position of legend ' num2str(i) ' has changed from ' pos0 ' to ' num2str(posn) ]);
                return
            end
            pos0=round(100*pos0)/100;
            posn=round(100*posn)/100;
            if min(posn==pos0)==0
                changed=1;
                disp(['Position of legend ' num2str(i) ' has changed from ' num2str(pos0) ' to ' num2str(posn) ]);
                return
            end
        end
    end
end

% Check for changes in vector legend
for i=1:nrsub
    if handles.figures(ifig).figure.subplots(i).subplot.PlotVectorLegend
        h=findobj(gcf,'Tag','vectorlegend','UserData',[ifig,i]);
        pos0=handles.figures(ifig).figure.subplots(i).subplot.VectorLegendPosition;
        pos0=round(100*pos0(1:2))/100;
        posn=get(h,'Position')/handles.figures(ifig).figure.cm2pix;
        posn=round(100*posn(1:2))/100;
        if min(posn==pos0)==0
            changed=1;
            disp(['Position of vector legend ' num2str(i) ' has changed from ' num2str(pos0) ' to ' num2str(posn) ]);
            return
        end
    end
end

% Check for changes in scale bar
for i=1:nrsub
    if handles.figures(ifig).figure.subplots(i).subplot.PlotScaleBar
        h=findobj(gcf,'Tag','scalebar','UserData',[ifig,i]);
        pos0=handles.figures(ifig).figure.subplots(i).subplot.ScaleBar(1:2);
        pos0=round(100*pos0(1:2))/100;
        posn=get(h,'Position')/handles.figures(ifig).figure.cm2pix;
        posn=round(100*posn(1:2))/100;
        if min(posn==pos0)==0
            changed=1;
            disp(['Position of scale bar ' num2str(i) ' has changed from ' num2str(pos0) ' to ' num2str(posn) ]);
            return
        end
    end
end

% Check for changes in north arrow
for i=1:nrsub
    if handles.figures(ifig).figure.subplots(i).subplot.PlotNorthArrow
        h=findobj(gcf,'Tag','northarrow','UserData',[ifig,i]);
        pos0=handles.figures(ifig).figure.subplots(i).subplot.NorthArrow(1:3);
        pos0=round(100*pos0(1:3))/100;
        posn=get(h,'Position')/handles.figures(ifig).figure.cm2pix;
        posn=round(100*posn(1:3))/100;
        if min(posn==pos0)==0
            changed=1;
            disp(['Position of north arrow ' num2str(i) ' has changed from ' num2str(pos0) ' to ' num2str(posn) ]);
            return
        end
    end
end

% Check for changes in annotations
overl=findall(gcf,'Tag','scribeOverlay');
ch0=get(overl,'Children');
nann=0;
for k=1:length(ch0)
    tg=get(ch0(k),'Tag');
    str={'line','arrow','doublearrow','textbox','ellipse','rectangle'};
    ii=strmatch(tg,str,'exact');
    if ~isempty(ii)
        nann=nann+1;
        ch(nann)=ch0(k);
    end
end
if nann~=handles.figures(ifig).figure.nrannotations
    changed=1;
    disp(['Number of annotations has changed from ' num2str(handles.figures(ifig).figure.nrannotations) ' to ' num2str(nann)]);
    return
end

for k=1:nann
    usd=get(ch(k),'UserData');
    ii=usd(2);
    cc=ch(ii);
    PaperSize=handles.figures(ifig).figure.PaperSize;
    Position0=handles.figures(ifig).figure.Annotation(k).Position;
    Position0(1)=Position0(1)/PaperSize(1);
    Position0(2)=Position0(2)/PaperSize(2);
    Position0(3)=Position0(3)/PaperSize(1);
    Position0(4)=Position0(4)/PaperSize(2);
    Position0=round(100*Position0)/100;
    Positionn=get(cc,'Position');
    Positionn=round(100*Positionn)/100;
    if min(Positionn==Position0)==0
        changed=1;
        disp(['Position annotation ' num2str(k) ' has changed from ' num2str(Position0) ' to ' num2str(Positionn)]);
        return
    end
end

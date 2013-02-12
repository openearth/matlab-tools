function handles=muppet_makeFigure(handles,ifig,mode)

% Delete existing figure
switch mode
    case{'export','guiexport'}
    otherwise
        figh=findobj('tag','figure','userdata',ifig);
        delete(figh);
end

handles=muppet_prepareFigure(handles,ifig,mode);

fig=handles.figures(ifig).figure;

% Make frame
muppet_makeFrame(handles,ifig);

clfix=0;
nn=0;
% Check if colorfix is necessary. Colorfix i.c.w. painters gives problems
for j=1:fig.nrsubplots
    for k=1:fig.subplots(j).subplot.nrdatasets
        switch lower(fig.subplots(j).subplot.datasets(k).dataset.plotroutine)
            case {'plotcontourmap','plotcontourmaplines','plotpatches','plotshadesmap','plotvectormagnitude'},
                nn=nn+1;
                if nn>1
                    kk=strmatch(fig.subplots(j).subplot.colormap,clmap);
                    if isempty(kk)
                        clfix=1;
                    end
                end
                clmap{nn}=fig.subplots(j).subplot.colormap;
        end
    end
end

% Make subplots
for j=1:fig.nrsubplots
    switch fig.subplots(j).subplot.type
        case{'annotation'}
            for k=1:fig.subplots(j).subplot.nrdatasets
                muppet_plotDataset(handles,ifig,j,k,'new');
            end
        otherwise
            muppet_makeSubplot(handles,ifig,j);
            fig.subplots(j).subplot.colorbar.changed=0;
            fig.subplots(j).subplot.legend.changed=0;
            fig.subplots(j).subplot.vectorlegend.changed=0;
            fig.subplots(j).subplot.northarrow.changed=0;
            fig.subplots(j).subplot.scalebar.changed=0;
            fig.subplots(j).subplot.limitschanged=0;
            fig.subplots(j).subplot.positionchanged=0;
            fig.subplots(j).subplot.annotationsadded=0;
            fig.subplots(j).subplot.annotationschanged=0;

            if clfix
                colorfix;
            end
    end
end

handles.figures(ifig).figure=fig;

for j=1:fig.nrsubplots
    % Do stuff with boxes for 3D plots, not sure anymore why this is
    % necessary ...
    if strcmp(fig.subplots(j).subplot.type,'3d') && fig.subplots(j).subplot.drawbox
        h=findobj(gcf,'Tag','framebox');
        for ii=1:length(h)
            axes(h(ii));
            set(h(ii),'HitTest','off');
        end
        h=findobj(gcf,'Tag','frametextaxis');
        for ii=1:length(h)
            axes(h(ii));
            set(h(ii),'HitTest','off');
        end
        set(gcf,'Visible','off');
        h=findobj(gcf,'Tag','logoaxis');
        for ii=1:length(h)
            axes(h(ii));
            set(h(ii),'HitTest','off');
        end
        set(gcf,'Visible','off');
    end
end


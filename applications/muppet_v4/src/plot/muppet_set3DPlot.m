function muppet_set3DPlot(handles,ifig,isub)

plt=handles.figures(ifig).figure.subplots(isub).subplot;
fontred=handles.figures(ifig).figure.fontreduction;
cm2pix=handles.figures(ifig).figure.cm2pix;
units=handles.figures(ifig).figure.units;

if plt.perspective
    set(gca,'Projection','perspective');
end
 
daspect([1/plt.dataaspectratio(1) 1/plt.dataaspectratio(2) 1/plt.dataaspectratio(3)]);

view(gca,[plt.cameraangle(1),plt.cameraangle(2)]);
set(gca,'CameraTarget',plt.cameratarget);
set(gca,'CameraViewAngle',plt.cameraviewangle);

h=light;
set(h,'style','local');
lightangle(h,plt.lightazimuth,plt.lightelevation);

set(gca,'Units',units);
set(gca,'Position',plt.position*cm2pix);
set(gca,'Layer','top');

if plt.drawbox==0
    
    set(gca,'XLim',[plt.xmin plt.xmax]);
    set(gca,'YLim',[plt.ymin plt.ymax]);
    set(gca,'ZLim',[plt.zmin plt.zmax]);

    if plt.xtick~=-999.0
        xtickstart=plt.xtick*floor(plt.xmin/plt.xtick);
        xtickstop=plt.xtick*ceil(plt.xmax/plt.xtick);
        xtick=xtickstart:plt.xtick:xtickstop;
        set(gca,'xtick',xtick,'FontSize',10*fontred);

        if plt.decimalsx>=0
            frmt=['%0.' num2str(plt.decimalsx) 'f'];
            for i=1:size(xtick,2)
                xlabls{i}=sprintf(frmt,xtick(i));
            end
            set(gca,'xticklabel',xlabls);
        end

        if plt.decimalsx==-999
            for i=1:size(xtick,2)
                xlabls{i}='';
            end
            set(gca,'xticklabel',xlabls);
        end
        
        if plt.XGrid
            set(gca,'Xgrid','on');
        else
            set(gca,'Xgrid','off');
        end

    else
        tick(gca,'x','none');
    end

    if plt.ytick~=-999.0
        ytickstart=plt.ytick*floor(plt.ymin/plt.ytick);
        ytickstop=plt.ytick*ceil(plt.ymax/plt.ytick);
        ytick=ytickstart:plt.ytick:ytickstop;
        set(gca,'ytick',ytick,'FontSize',10*fontred);

        if plt.decimalsy>=0
            frmt=['%0.' num2str(plt.decimalsy) 'f'];
            for i=1:size(ytick,2)
                ylabls{i}=sprintf(frmt,ytick(i));
            end
            set(gca,'yticklabel',ylabls);
        end

        if plt.decimalsy==-999
            for i=1:size(ytick,2)
                ylabls{i}='';
            end
            set(gca,'zticklabel',ylabls);
        end

        
        if plt.ygrid
            set(gca,'Ygrid','on');
        else
            set(gca,'Ygrid','off');
        end

    else
        tick(gca,'y','none');
    end

    if plt.ztick~=-999.0
        ztickstart=plt.ztick*floor(plt.zmin/plt.ztick);
        ztickstop=plt.ztick*ceil(plt.zmax/plt.ztick);
        ztick=ztickstart:plt.ztick:ztickstop;
        set(gca,'ztick',ztick,'FontSize',10*fontred);

        if plt.decimalsz>=0
            frmt=['%0.' num2str(plt.decimalsz) 'f'];
            for i=1:size(ztick,2)
                zlabls{i}=sprintf(frmt,ztick(i));
            end
            set(gca,'zticklabel',zlabls);
        end

        if plt.decimalsz==-999
            for i=1:size(ztick,2)
                zlabls{i}='';
            end
            set(gca,'zticklabel',zlabls);
        end

        if plt.zgrid
            set(gca,'Zgrid','on');
        else
            set(gca,'Zgrid','off');
        end

    else
        tick(gca,'z','none');
    end

else
    
    set(gca,'XLim',[plt.xmin plt.xmax]);
    set(gca,'YLim',[plt.ymin plt.ymax]);
    set(gca,'ZLim',[plt.zmin plt.zmax]);

    
    tick(gca,'x','none');
    tick(gca,'y','none');
    tick(gca,'z','none');
    axis off;

end

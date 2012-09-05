function leg=muppet_setLegend(fig,ifig,isub)

plt=fig.subplots(isub).subplot;

leg=[];

h=findobj(gcf,'Tag','legend','UserData',[ifig,isub]);
delete(h);

kk=0;
hnd(1)=0;
for k=1:plt.nrdatasets
    if ~isempty(plt.datasets(k).dataset.legendtext) && ~isempty(plt.datasets(k).dataset.handle)
        kk=kk+1;
        txt{kk}=plt.datasets(k).dataset.legendtext;
        hnd(kk)=plt.datasets(k).dataset.handle;
    end
end

if sum(hnd)>0
    
    leg=legend(hnd,txt);
    
    if ~plt.legend.border
        if fig.cm2pix==1
            legend boxoff;
        else
            set(leg,'Color','none');
            set(leg,'XColor',[0.8 0.8 0.8]);
            set(leg,'YColor',[0.8 0.8 0.8]);
        end            
    else
        set(leg,'Color',colorlist('getrgb','color',plt.legend.color));
    end
    
    set(leg,'Unit',fig.units);
    set(leg,'Orientation',plt.legend.orientation);
    set(leg,'FontName',plt.legend.font.name);
    set(leg,'FontSize',plt.legend.font.size*fig.fontreduction);
    set(leg,'FontWeight',plt.legend.font.weight);
    set(leg,'FontAngle',plt.legend.font.angle);
    set(leg,'TextColor',colorlist('getrgb','color',plt.legend.font.color));

    if ischar(plt.legend.position)
        set(leg,'Location',plt.legend.position);
    else
        pos=plt.legend.position;
        pos(3)=max(pos(3),0.2);
        pos(4)=max(pos(4),0.2);
        set(leg,'Position',pos*fig.cm2pix);
    end
    set(leg,'Tag','legend');
    set(findobj(leg,'type','text'),'HitTest','off');
    legenddata.i=ifig;
    legenddata.j=isub;
    setappdata(leg,'legenddata',legenddata);
end

set(leg,'UserData',[ifig,isub]);


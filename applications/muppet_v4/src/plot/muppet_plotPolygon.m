function handles=muppet_plotPolygon(handles,i,j,k)

plt=handles.figures(i).figure.subplots(j).subplot;
nr=plt.datasets(k).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;

tmmrk=0;

if isfield(opt,'timemarker')
    if opt.timemarker
        tmmrk=1;
    end    
end

x=data.x;
y=data.y;

if opt.fillclosedpolygons==1
    ldb=[x y];
%     h2=filledLDB(ldb,[0 0 0],[0 1 0],opt.maxdistance,opt.polygonelevation);
    h2=filledLDB(ldb,[0 0 0],[0 1 0],opt.maxdistance,10000);
end
% z=zeros(size(x));
% z=z+opt.polygonelevation;

if tmmrk
    xm=interp1(data.times,x,opt.markertime);
    ym=interp1(data.times,y,opt.markertime);
    it=find(data.times<=opt.markertime,1,'last');
    x=x(1:it);
    y=y(1:it);
    if size(x,1)==1
        % row
        x=[x xm];
        y=[y ym];
    else
        % column        
        x=[x;xm];
        y=[y;ym];
    end
end
 
    h1=line(x,y);
    
    % z=zeros(size(get(h1,'ZData')))+opt.polygonelevation;
    % set(h1,'ZData',z);
    
    if ~isempty(opt.linestyle)
        set(h1,'LineStyle',opt.linestyle);
    else
        set(h1,'LineStyle','none');
    end
    
    set(h1,'LineWidth',opt.linewidth,'Color',colorlist('getrgb','color',opt.linecolor));
    
    if opt.fillclosedpolygons
        set(h2,'EdgeColor',colorlist('getrgb','color',opt.linecolor));
        set(h2,'FaceColor',colorlist('getrgb','color',opt.fillcolor));
        %     z=zeros(size(get(h1,'ZData')))+opt.polygonelevation;
        %     z=zeros(size(get(h1,'XData')))+1000;
        %     set(h1,'ZData',z);
        %
        x00=[0 1 1];y00=[0 0 1];
        htmp=patch(x00,y00,'k','Tag','patch');
        set(htmp,'EdgeColor',colorlist('getrgb','color',opt.linecolor));
        set(htmp,'FaceColor',colorlist('getrgb','color',opt.fillcolor));
        set(htmp,'LineWidth',opt.linewidth);
        if ~isempty(opt.linestyle)
            set(htmp,'LineStyle',opt.linestyle);
        else
            set(htmp,'LineStyle','none');
        end
        set(htmp,'Visible','off');
        handles.figures(i).figure.subplots(j).subplot.datasets(k).dataset.handle=htmp;
    else
        handles.figures(i).figure.subplots(j).subplot.datasets(k).dataset.handle=h1;
    end
    
% end

if tmmrk
    p=plot(xm,ym,'o');
    set(p,'Marker',opt.marker);
    set(p,'MarkerEdgeColor',colorlist('getrgb','color',opt.markeredgecolor));
    set(p,'MarkerFaceColor',colorlist('getrgb','color',opt.markerfacecolor));
    set(p,'MarkerSize',opt.markersize);
else
    set(h1,'Marker',opt.marker);
    set(h1,'MarkerEdgeColor',colorlist('getrgb','color',opt.markeredgecolor));
    set(h1,'MarkerFaceColor',colorlist('getrgb','color',opt.markerfacecolor));
    set(h1,'MarkerSize',opt.markersize);
end

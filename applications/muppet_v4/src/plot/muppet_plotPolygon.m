function h2=muppet_plotPolygon(handles,i,j,k)

plt=handles.figures(i).figure.subplots(j).subplot;
nr=plt.datasets(k).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;

x=data.x;
y=data.y;

if opt.fillclosedpolygons==1
    ldb=[x y];
%     h2=filledLDB(ldb,[0 0 0],[0 1 0],opt.maxdistance,opt.polygonelevation);
    h2=filledLDB(ldb,[0 0 0],[0 1 0],opt.maxdistance,10000);
end
% z=zeros(size(x));
% z=z+opt.polygonelevation;

if opt.timemarker.enable

    if size(x,1)==1
        % Data must be stored in column vector
        x=x';
        y=y';
        data.times=data.times';
    end
    
    xm=interp1(data.times,x,opt.timemarker.time);
    ym=interp1(data.times,y,opt.timemarker.time);

    if isnan(xm)
        % xm and ym contain NaNs
        if opt.timemarker.showfirstposition
            % But we do want to show the marker
            % Check if time is past last available time
            ifirst=find(~isnan(x),1,'first');
            if opt.timemarker.time<data.times(ifirst)
                % All the real data happen earlier
                xm=x(ifirst);
                ym=y(ifirst);
            end
        end
        if opt.timemarker.showlastposition
            % But we do want to show the marker
            % Check if time is past last available time
            ilast=find(~isnan(x),1,'last');
            if opt.timemarker.time>data.times(ilast)
                % All the real data happen earlier
                xm=x(ilast);
                ym=y(ilast);
            end
        end
    end
    
    switch opt.timemarker.trackoption
        case{'uptomarker'}
            it=find(data.times<=opt.timemarker.time,1,'last');
            if isempty(it)
                it=1;
            end
            
            x=x(1:it,:);
            y=y(1:it,:);

%             if size(x,1)==1
%                 % row
%                 x=[x xm];
%                 y=[y ym];
%             else
                % column

                x=[x;xm];
                y=[y;ym];

                %             end
        case{'frommarker'}
            it=find(data.times>=opt.timemarker.time,1,'first');
            if isempty(it)
                it=length(x);
            end
            x=x(it:end,:);
            y=y(it:end,:);
%             if size(x,1)==1
%                 % row
%                 x=[xm x];
%                 y=[ym y];
%             else
                % column
                x=[xm;x];
                y=[ym;y];
%             end
        case{'none'}
            x=NaN;
            y=NaN;
        case{'complete'}
            % No need to change x and y
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
    h2=htmp;
else
    h2=h1;
end

if opt.timemarker.enable
    p=plot(xm,ym,'o');
    set(p,'Marker',opt.timemarker.marker);
    set(p,'MarkerEdgeColor',colorlist('getrgb','color',opt.timemarker.edgecolor));
    set(p,'MarkerFaceColor',colorlist('getrgb','color',opt.timemarker.facecolor));
    set(p,'MarkerSize',opt.timemarker.size);
end

set(h1,'Marker',opt.marker);
set(h1,'MarkerEdgeColor',colorlist('getrgb','color',opt.markeredgecolor));
set(h1,'MarkerFaceColor',colorlist('getrgb','color',opt.markerfacecolor));
set(h1,'MarkerSize',opt.markersize);

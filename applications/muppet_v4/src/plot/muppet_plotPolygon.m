function h2=muppet_plotPolygon(handles,i,j,k)

plt=handles.figures(i).figure.subplots(j).subplot;
nr=plt.datasets(k).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;

x=data.x;
y=data.y;

if opt.fillclosedpolygons==1
    ldb=[x y];
    h2=filledLDB(ldb,'none',[0 1 0],opt.maxdistance,10000);
    if iscell(h2)
        h2=cell2mat(h2);
    end
    set(h2,'LineStyle','none');
end
% z=zeros(size(x));
% z=z+opt.polygonelevation;

if size(x,1)==1
    % Data must be stored in column vector
    x=x';
    y=y';
    data.times=data.times';
end
ntracks=size(x,2);

xmfirst=zeros(1,ntracks);
xmfirst(xmfirst==0)=NaN;
ymfirst=xmfirst;
xmlast=xmfirst;
ymlast=xmlast;

if opt.originmarker.enable
    for itrack=1:ntracks
        ifirst=find(~isnan(x(:,itrack)),1,'first');
        xmfirst(itrack)=x(ifirst,itrack);
        ymfirst(itrack)=y(ifirst,itrack);
    end
end

transp=0;

if opt.timemarker.enable
    
    transp=1;
    
    for itrack=1:ntracks
        
        % Last position
        xmlast(itrack)=interp1(data.times,x(:,itrack),opt.timemarker.time);
        ymlast(itrack)=interp1(data.times,y(:,itrack),opt.timemarker.time);
        
        if isnan(xmlast(itrack))
            % xm and ym contain NaNs
            if opt.timemarker.showlastposition
                % But we do want to show the marker
                % Check if time is past last available time
                ilast=find(~isnan(x(:,itrack)),1,'last');
                if opt.timemarker.time>data.times(ilast)
                    % All the real data happen earlier
                    xmlast(itrack)=x(ilast,itrack);
                    ymlast(itrack)=y(ilast,itrack);
                end
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
            
            x=[x;xmlast];
            y=[y;ymlast];
            
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

if transp
    z=zeros(size(x))-1;
    h1=patchline(x,y,z,'edgealpha',0.05);
    set(h1,'LineWidth',opt.linewidth,'EdgeColor',colorlist('getrgb','color',opt.linecolor));
else
%    z=zeros(size(x));
%    z=z-100;
%    h1=line(x,y,z);
    h1=line(x,y);
    set(h1,'LineWidth',opt.linewidth,'Color',colorlist('getrgb','color',opt.linecolor));
end

% z=zeros(size(get(h1,'ZData')))+opt.polygonelevation;
% set(h1,'ZData',z);

if ~isempty(opt.linestyle)
    set(h1,'LineStyle',opt.linestyle);
else
    set(h1,'LineStyle','none');
end

%set(h1,'LineWidth',opt.linewidth,'Color',colorlist('getrgb','color',opt.linecolor));
%set(h1,'LineWidth',opt.linewidth,'EdgeColor',colorlist('getrgb','color',opt.linecolor));

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
    p=plot(xmlast,ymlast,'o');
    set(p,'Marker',opt.timemarker.marker);
    set(p,'MarkerEdgeColor',colorlist('getrgb','color',opt.timemarker.edgecolor));
    set(p,'MarkerFaceColor',colorlist('getrgb','color',opt.timemarker.facecolor));
    set(p,'MarkerSize',opt.timemarker.size);
end
    
if opt.originmarker.enable
    p=plot(xmfirst,ymfirst,'o');
    set(p,'Marker',opt.originmarker.marker);
    set(p,'MarkerEdgeColor',colorlist('getrgb','color',opt.originmarker.edgecolor));
    set(p,'MarkerFaceColor',colorlist('getrgb','color',opt.originmarker.facecolor));
    set(p,'MarkerSize',opt.originmarker.size);    
end

set(h1,'Marker',opt.marker);
set(h1,'MarkerEdgeColor',colorlist('getrgb','color',opt.markeredgecolor));
set(h1,'MarkerFaceColor',colorlist('getrgb','color',opt.markerfacecolor));
set(h1,'MarkerSize',opt.markersize);
